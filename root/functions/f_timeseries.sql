DROP FUNCTION IF EXISTS root.f_timeseries (VARCHAR(256), VARCHAR(256),BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_timeseries (var_schema_name VARCHAR(256), var_table_name VARCHAR(256),var_versioning BOOLEAN)
    RETURNS TEXT
    LANGUAGE plpgsql
AS $Body$
DECLARE
    pk_columns TEXT;
    first_comma int;
    first_pk_column TEXT;
    columns TEXT DEFAULT '';
    pk_column record;
    columns_info varchar(256)[][2];
    column_info varchar(256)[2];
    condition TEXT;
    new_columns TEXT DEFAULT '';
    new_columns_datatype TEXT DEFAULT '';
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
    view_name VARCHAR(256);
    target_table VARCHAR(256);
    versioned_view_name VARCHAR(256);
    double_dollar VARCHAR(4);
    sql TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), CHR(36)));
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
    versioned_view_name:= FORMAT('%s.vv_%s', var_schema_name, SUBSTRING(var_table_name,4));
    IF var_versioning THEN
        target_table := versioned_view_name;
    ELSE
        target_table := table_name;
    END IF;
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
    $Dynamic$
    , table_name)::TEXT;
    EXECUTE sql INTO pk_columns;

    first_comma:= POSITION(',' IN pk_columns);
    IF first_comma = 0 THEN
        first_pk_column:= REPLACE(pk_columns,'c.','');
    ELSE
        first_pk_column:= REPLACE(SUBSTRING(pk_columns FROM 1 FOR first_comma - 1),'c.','');
    END IF;

    -- table columns with NEW prefix
    EXECUTE FORMAT($Dynamic$
        SELECT ARRAY(
        SELECT
            ARRAY[
                  CONCAT('prefix.', c.column_name)
                , p.typname]
            FROM information_schema.columns c
            LEFT JOIN pg_type p ON c.data_type::regtype::oid = p.oid
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I') 
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT into columns_info;
    
    FOREACH column_info SLICE 1 IN ARRAY columns_info
    LOOP
        columns:= CONCAT_WS(',',columns,REPLACE(column_info[1],'prefix.',''));
        new_columns:=CONCAT_WS(',',new_columns,column_info[1]);
        new_columns_datatype:=CONCAT_WS(',',new_columns_datatype,FORMAT($$CAST(%s AS %s)$$,column_info[1],column_info[2])::TEXT);
        
    END LOOP; 
    columns := SUBSTRING(columns,2);
    new_columns := SUBSTRING(new_columns,2);
    new_columns_datatype := SUBSTRING(new_columns_datatype,2);
    

    -- table columns with datatype für input parameters in function
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('prefix.' || c.column_name || CASE WHEN lower(c.data_type) = lower('integer') THEN
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
            a.attname AS NAME 
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid
            AND a.attnum = ANY (i.indkey)
        WHERE
            1 = 1
            AND i.indrelid = '%s'::REGCLASS
            AND i.indisprimary $Dynamic$, table_name)::TEXT;
        FOR pk_column IN EXECUTE sql
        LOOP
            IF pk_column.NAME NOT IN ('valid_from', 'valid_to', 'changed_by') THEN
                condition:= CONCAT(condition, ' AND c.', pk_column.NAME, ' = NEW.', pk_column.NAME);
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
        WHERE 1 = 1 
        %s
        AND c.valid_to < COALESCE(NEW.valid_to, c.valid_to)
        AND c.valid_from < NEW.valid_from
        AND c.valid_to > NEW.valid_from 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;

    sql_b:= FORMAT($Dynamic$
        SELECT
            %s, 'B' AS solution FROM %s c
        WHERE 1 = 1 
        %s
        AND c.valid_from > NEW.valid_from
        AND c.valid_from < COALESCE(NEW.valid_to, c.valid_to)
        AND c.valid_to >= COALESCE(NEW.valid_to, c.valid_to) 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;

    sql_c2:= FORMAT($Dynamic$
        SELECT
            %s, 'C2' AS solution FROM %s c
        WHERE 1 = 1 
        %s
        AND c.valid_from < NEW.valid_from
        AND c.valid_to = COALESCE(NEW.valid_to, c.valid_to) 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;

    sql_c3:= FORMAT($Dynamic$
        SELECT
            %s, 'C3' AS solution FROM %s c
        WHERE 1 = 1 
        %s
        AND c.valid_from = NEW.valid_from
        AND c.valid_to > COALESCE(NEW.valid_to, c.valid_to) 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;

    sql_c4:= FORMAT($Dynamic$
        SELECT
            %s, 'C4' AS solution FROM %s c
        WHERE 1 = 1 
        %s
        AND c.valid_from < NEW.valid_from
        AND c.valid_to > COALESCE(NEW.valid_to, c.valid_to) 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;

    sql_d:= FORMAT($Dynamic$
        SELECT
            %s, 'D' AS solution FROM %s c
        WHERE 1 = 1 
        %s
        AND c.valid_from >= NEW.valid_from
        AND c.valid_to <= COALESCE(NEW.valid_to, c.valid_to) 
        $Dynamic$
        , pk_columns
        , table_name
        , condition)::TEXT;
                         
    -- DUBLICATE
    sql_dublicate:= FORMAT($Dynamic$
        ARRAY(
        SELECT 
            'INSERT INTO %1$s (%2$s) VALUES (' || Chr(39) || CONCAT_WS(Chr(39) || ',' || Chr(39),%3$s) || Chr(39) || ');' 
        FROM %4$s a
        RIGHT JOIN (%5$s) b %6$s)
    $Dynamic$
    , target_table
    , columns
    , REPLACE(REPLACE(REPLACE(new_columns_datatype, 'prefix.', 'a.'), 'a.valid_from', 'NEW.valid_to'), 'a.changed_by', 'NEW.changed_by')
    , table_name
    , sql_c4
    , join_condition)::TEXT;

    update_columns:= REPLACE(new_columns_datatype, 'prefix.', 'a.');
    update_columns:= REPLACE(update_columns, 'a.valid_to', 
        $Dynamic$ 
        CASE WHEN b.solution IN ('A', 'C2', 'C4') THEN
            NEW.valid_from
        ELSE
            a.valid_to
        END --AS valid_to 
        $Dynamic$);
    update_columns:= REPLACE(update_columns, 'a.valid_from', 
        $Dynamic$ 
        CASE WHEN b.solution IN ('B', 'C3') THEN
            COALESCE(NEW.valid_to, a.valid_to)
        ELSE
            a.valid_from
        END --AS valid_from 
        $Dynamic$);
    update_columns:= REPLACE(update_columns, 'a.changed_by', 'NEW.changed_by');

    sql_update:= FORMAT($Dynamic$ 
        ARRAY(
        SELECT 
            'INSERT INTO %1$s (%2$s) VALUES (' || Chr(39) || CONCAT_WS(Chr(39) || ',' || Chr(39),%3$s)  || Chr(39) || ');' 
        FROM %4$s a
        INNER JOIN (%5$s) b %6$s)
    $Dynamic$
    , target_table
    , columns
    , update_columns
    , table_name
    , CONCAT_WS(CHR(10) || 'UNION ', sql_a, sql_b, sql_c2, sql_c3, sql_c4)
    , join_condition)::TEXT;


    sql_del:= FORMAT($Dynamic$ 
    DELETE FROM %s a
        USING (%s) b %s
    $Dynamic$
    , target_table
    , CONCAT_WS(CHR(10) || ' UNION ', sql_a, sql_b, sql_c2, sql_c3, sql_c4, sql_d)
    , using_condition)::TEXT;
    
    sql_insert:= FORMAT($Dynamic$ 
    INSERT INTO %s (%s)
        VALUES (%s)
    $Dynamic$
    , target_table
    , columns
    , REPLACE(new_columns_datatype,'prefix.','NEW.'))::TEXT;

    sql := FORMAT($Dynamic$ 
    insert_sql_dublicate :=%s;
    insert_sql_update := %s;

    %s;

    FOREACH insert_sql IN ARRAY insert_sql_dublicate
    LOOP
        EXECUTE insert_sql;
    END LOOP; 
    FOREACH insert_sql IN ARRAY insert_sql_update
    LOOP
        EXECUTE insert_sql;
    END LOOP; 
    %s;
    $Dynamic$  
    , sql_dublicate
    , sql_update  
    , sql_del
    , sql_insert
    )::TEXT;
    
    RETURN sql;
END;
$Body$
