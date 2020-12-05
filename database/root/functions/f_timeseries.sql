DROP FUNCTION IF EXISTS root.f_timeseries (VARCHAR(256), VARCHAR(256));

CREATE OR REPLACE FUNCTION root.f_timeseries (var_schema_name VARCHAR(256), var_table_name VARCHAR(256))
    RETURNS void
    LANGUAGE plpgsql
AS $Body$
DECLARE
    pk_columns TEXT;
    first_comma int;
    first_pk_column TEXT;
    columns TEXT;
    pk_column record;
    condition TEXT;
    new_columns TEXT;
    update_columns TEXT;
    input_columns TEXT;
    values_placeholder TEXT;
    join_condition TEXT;
    using_condition TEXT;
    sql_a TEXT;
    sql_b TEXT;
    sql_c2 TEXT;
    sql_c3 TEXT;
    sql_c4 TEXT;
    sql_d TEXT;
    sql_del TEXT;
    sql_dublicate TEXT;
    sql_dublicate2 TEXT;
    sql_temp TEXT;
    sql_temp_drop TEXT;
    sql_update TEXT;
    sql_insert TEXT;
    sql_f TEXT;
    sql_f_afterburner TEXT;
    table_name VARCHAR(256);
    temp_table_name VARCHAR(256);
    view_name VARCHAR(256);
    double_dollar VARCHAR(4);
    sql TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), CHR(36)));
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    temp_table_name:= FORMAT('%s.%s', var_schema_name, CONCAT('tmp_timeseries_', var_table_name));
    view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
    -- PRIMARY KEY Columns
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('c.' || a.attname, ', ')
            FROM pg_index i
            JOIN pg_attribute a ON a.attrelid = i.indrelid
            AND a.attnum = ANY (i.indkey)
        WHERE
            1 = 1
            AND i.indrelid = '%s'::REGCLASS
            AND i.indisprimary;
    $Dynamic$,
    table_name)::TEXT;
    EXECUTE sql INTO pk_columns;
    first_comma:= POSITION(',' IN pk_columns);
    IF first_comma = 0 THEN
        first_pk_column:= REPLACE(pk_columns,'c.','');
    ELSE
        first_pk_column:= REPLACE(SUBSTRING(pk_columns FROM 1 FOR first_comma - 1),'c.','');
    END IF;
    -- table columns
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(c.column_name, ',')
            FROM information_schema.columns c
        WHERE
            1 = 1
            AND table_schema = '%I'
            AND table_name = '%I' $Dynamic$, var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO columns;
    -- table columns with NEW prefix
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CONCAT('var_', c.column_name), ',')
            FROM information_schema.columns c
        WHERE
            1 = 1
            AND table_schema = '%I'
            AND table_name = '%I' $Dynamic$, var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO new_columns;
    -- table columns with datatype für input parameters in function
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('var_' || c.column_name || CASE WHEN lower(c.data_type) = lower('integer') THEN
                    ' INT'
                    WHEN lower(c.data_type) = lower('character varying') THEN
                    ' VARCHAR(' || character_maximum_length || ')'
                    WHEN lower(c.data_type) = lower('TIMESTAMP WITH TIME zone') THEN
                    ' TIMESTAMPTZ'
            END, ',')
        FROM information_schema.columns c
    WHERE
        1 = 1
        AND table_schema = '%I'
        AND table_name = '%I' $Dynamic$, var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO input_columns;
    -- Value placeholder for each column
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('%s', ',')
            FROM information_schema.columns c
        WHERE
            1 = 1
            AND table_schema = '%I'
            AND table_name = '%I' $Dynamic$, CONCAT(CHR(37), CHR(76)), var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO values_placeholder;
    -- PRIMARY KEY Columns except timeseries specific columns
    sql:= FORMAT($Dynamic$
        SELECT
            a.attname AS NAME FROM pg_index i
            JOIN pg_attribute a ON a.attrelid = i.indrelid
            AND a.attnum = ANY (i.indkey)
        WHERE
            1 = 1
            AND i.indrelid = '%s'::REGCLASS
            AND i.indisprimary $Dynamic$, table_name)::TEXT;
        FOR pk_column IN EXECUTE sql
        LOOP
            IF pk_column.NAME NOT IN ('valid_from', 'valid_to', 'changed_by') THEN
                condition:= CONCAT(condition, ' AND c.', pk_column.NAME, ' = var_', pk_column.NAME);
            END IF;
            IF join_condition NOT LIKE '%ON%' OR join_condition IS NULL THEN
                join_condition:= CONCAT(join_condition, ' ON a.', pk_column.NAME, ' = b.', pk_column.NAME);
                using_condition:= CONCAT(using_condition, ' WHERE a.', pk_column.NAME, ' = b.', pk_column.NAME);
            ELSE
                join_condition:= CONCAT(join_condition, ' AND a.', pk_column.NAME, ' = b.', pk_column.NAME);
                using_condition:= CONCAT(using_condition, ' AND a.', pk_column.NAME, ' = b.', pk_column.NAME);
            END IF;
        END LOOP;
    sql_a:= FORMAT($Dynamic$
        SELECT
            %s, 'A' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_to < COALESCE(var_valid_to, c.valid_to)
            AND c.valid_from < var_valid_from
            AND c.valid_to > var_valid_from $Dynamic$, pk_columns, table_name, condition)::TEXT;
    sql_b:= FORMAT($Dynamic$
        SELECT
            %s, 'B' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_from > var_valid_from
            AND c.valid_from < COALESCE(var_valid_to, c.valid_to)
            AND c.valid_to >= COALESCE(var_valid_to, c.valid_to) $Dynamic$, pk_columns, table_name, condition)::TEXT;
    sql_c2:= FORMAT($Dynamic$
        SELECT
            %s, 'C2' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_from < var_valid_from
            AND c.valid_to = COALESCE(var_valid_to, c.valid_to) $Dynamic$, pk_columns, table_name, condition)::TEXT;
    sql_c3:= FORMAT($Dynamic$
        SELECT
            %s, 'C3' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_from = var_valid_from
            AND c.valid_to > COALESCE(var_valid_to, c.valid_to) $Dynamic$, pk_columns, table_name, condition)::TEXT;
    sql_c4:= FORMAT($Dynamic$
        SELECT
            %s, 'C4' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_from < var_valid_from
            AND c.valid_to > COALESCE(var_valid_to, c.valid_to) $Dynamic$, pk_columns, table_name, condition)::TEXT;
    sql_d:= FORMAT($Dynamic$
        SELECT
            %s, 'D' AS solution FROM %s c
        WHERE
            1 = 1 %s
            AND c.valid_from >= var_valid_from
            AND c.valid_to <= COALESCE(var_valid_to, c.valid_to) $Dynamic$, pk_columns, table_name, condition)::TEXT;
    -- DUBCLIATE Table as TEMP
    sql_temp:= FORMAT($Dynamic$
        PERFORM
            root.f_check_if_table_exists ('%s', '%s', TRUE);
    CREATE TABLE %s
AS (
    SELECT
        *
    FROM
        %s
)
    WITH NO DATA;
    $Dynamic$,
    var_schema_name,
    CONCAT('tmp_timeseries_', var_table_name),
    temp_table_name,
    table_name)::TEXT;
    -- DUBLICATE
    sql_dublicate:= FORMAT($Dynamic$ INSERT INTO %s
        SELECT
            %s FROM %s a
        RIGHT JOIN (%s) b %s;
    $Dynamic$,
    temp_table_name,
    REPLACE(REPLACE(REPLACE(new_columns, 'var_', 'a.'), 'a.valid_from', 'var_valid_to as valid_from'), 'a.changed_by', 'var_changed_by'),
    table_name,
    sql_c4,
    join_condition)::TEXT;
    update_columns:= REPLACE(new_columns, 'var_', 'a.');
    update_columns:= REPLACE(update_columns, 'a.valid_to', $Dynamic$ CASE WHEN b.solution IN ('A', 'C2', 'C4') THEN
            var_valid_from
        ELSE
            a.valid_to
    END AS valid_to $Dynamic$);
    update_columns:= REPLACE(update_columns, 'a.valid_from', $Dynamic$ CASE WHEN b.solution IN ('B', 'C3') THEN
            COALESCE(var_valid_to, a.valid_to)
        ELSE
            a.valid_from
    END AS valid_from $Dynamic$);
    update_columns:= REPLACE(update_columns, 'a.changed_by', 'var_changed_by as changed_by');
    sql_update:= FORMAT($Dynamic$ INSERT INTO %s
        SELECT
            %s FROM %s a
        INNER JOIN (%s) b %s;
    $Dynamic$,
    temp_table_name,
    update_columns,
    table_name,
    CONCAT_WS(CHR(10) || 'UNION ', sql_a, sql_b, sql_c2, sql_c3, sql_c4),
    join_condition)::TEXT;
    sql_del:= FORMAT($Dynamic$ DELETE FROM %s a
        USING (%s) b %s;
    $Dynamic$,
    table_name,
    CONCAT_WS(CHR(10) || ' UNION ', sql_a, sql_b, sql_c2, sql_c3, sql_c4, sql_d),
    using_condition)::TEXT;
    sql_insert:= FORMAT($Dynamic$ INSERT INTO %s (%s)
        VALUES (%s);
    $Dynamic$,
    temp_table_name,
    columns,
    new_columns)::TEXT;
    sql_dublicate2:= FORMAT($Dynamic$ IF (
                SELECT
                    COUNT(%s) > 0 FROM %s) THEN
                EXECUTE FORMAT('INSERT INTO %s SELECT * FROM %s;');
        END IF;
    $Dynamic$,
    first_pk_column,
    temp_table_name,
    table_name,
    temp_table_name)::TEXT;
    --columns, values_placeholder, REPLACE(new_columns, 'var_', 'var_dublicate.'));
    sql_temp_drop:= FORMAT($Dynamic$ DROP TABLE IF EXISTS %s;
            $Dynamic$,
            temp_table_name)::TEXT;
            sql_f:= FORMAT($Dynamic$ CREATE OR REPLACE FUNCTION %s.f_%s_timeseries (%s)
                    RETURNS void
                    LANGUAGE plpgsql
AS %s
BEGIN
    %s
END;
    %s $Dynamic$,
    var_schema_name,
    var_table_name,
    input_columns,
    double_dollar,
    CONCAT_WS(' ', sql_temp, sql_dublicate, sql_update, sql_insert, sql_del),
    double_dollar)::TEXT;
    sql_f_afterburner:= FORMAT($Dynamic$ CREATE OR REPLACE FUNCTION %s.f_%s_timeseries_afterburner (%s)
            RETURNS void
            LANGUAGE plpgsql
AS %s
BEGIN
    %s
END;
    %s $Dynamic$,
    var_schema_name,
    var_table_name,
    input_columns,
    double_dollar,
    CONCAT_WS(' ', sql_dublicate2, sql_temp_drop),
    double_dollar)::TEXT;
    EXECUTE sql_f;
    EXECUTE sql_f_afterburner;
END;
$Body$
