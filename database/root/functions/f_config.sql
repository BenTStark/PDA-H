DROP FUNCTION IF EXISTS root.f_config (VARCHAR(256), VARCHAR(256), BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_config (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), var_timeseries BOOLEAN, var_changelog BOOLEAN)
    RETURNS void
    LANGUAGE plpgsql
AS $Body$
DECLARE
    table_name VARCHAR(256);
    view_name VARCHAR(256);
    double_dollar VARCHAR(10);
    columns TEXT;
    new_columns TEXT;
    values_placeholder TEXT;
    sql_tf TEXT;
    sql_t TEXT;
    sql_v TEXT;
    functions TEXT;
    sql TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), 'Body', CHR(36)));
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
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
    -- table columns with NEW Prefix
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CONCAT('NEW.', c.column_name), ',')
            FROM information_schema.columns c
        WHERE
            1 = 1
            AND table_schema = '%I'
            AND table_name = '%I' $Dynamic$, var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO new_columns;
    -- Value placeholder for each column
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('%s', ',')
            FROM information_schema.columns c
        WHERE
            1 = 1
            AND table_schema = '%I'
            AND c.table_name = '%I' $Dynamic$, CONCAT(CHR(37), CHR(76)), var_schema_name, var_table_name)::TEXT;
    EXECUTE sql INTO values_placeholder;
    PERFORM
        root.f_drop_config (var_schema_name,
            var_table_name,
            'table');
    IF var_timeseries THEN
        PERFORM
            root.f_timeseries (var_schema_name,
                var_table_name);
        functions:= CONCAT(functions, FORMAT($Dynamic$
                PERFORM
                    %s.f_%s_timeseries (%s);
        $Dynamic$,
        var_schema_name,
        var_table_name,
        new_columns)::TEXT);
        functions:= CONCAT(functions, FORMAT($Dynamic$
                PERFORM
                    %s.f_%s_timeseries_afterburner (%s);
        $Dynamic$,
        var_schema_name,
        var_table_name,
        new_columns)::TEXT);
        sql_v:= FORMAT($Dynamic$ CREATE OR REPLACE VIEW %s
AS
SELECT
    %s FROM %s
WHERE
    1 = 1
    AND valid_from <= NOW()
    AND valid_to > NOW() $Dynamic$, view_name, columns, table_name)::TEXT;
    EXECUTE sql_v;
    sql_tf:= FORMAT($Dynamic$ CREATE OR REPLACE FUNCTION %s.tf_instead_of_v_%s ()
            RETURNS TRIGGER
            LANGUAGE 'plpgsql'
AS %s
BEGIN
    %s RETURN NULL;
END %s;
    $Dynamic$,
    var_schema_name,
    var_table_name,
    double_dollar,
    functions,
    double_dollar)::TEXT;
    sql_t:= FORMAT($Dynamic$ CREATE TRIGGER t_instead_of_v_%s INSTEAD OF INSERT
        OR
        UPDATE
            ON %s FOR EACH ROW EXECUTE PROCEDURE %s.tf_instead_of_v_%s ();
    $Dynamic$,
    var_table_name,
    view_name,
    var_schema_name,
    var_table_name)::TEXT;
    EXECUTE sql_tf;
    EXECUTE sql_t;
END IF;
IF var_changelog THEN
    PERFORM
        root.f_changelog (var_schema_name,
            var_table_name);
    functions:= CONCAT(functions, FORMAT($Dynamic$
            PERFORM
                %s.f_%s_changelog ();
    $Dynamic$,
    var_schema_name,
    var_table_name)::TEXT);

sql_t:= FORMAT($Dynamic$ CREATE TRIGGER t_after_%s AFTER INSERT
    OR DELETE
    OR
    UPDATE
        ON %s FOR EACH ROW EXECUTE PROCEDURE %s.tf_after_%s ();
$Dynamic$,
var_table_name,
table_name,
var_schema_name,
var_table_name)::TEXT;
EXECUTE sql_t;
END IF;
END;
$Body$
