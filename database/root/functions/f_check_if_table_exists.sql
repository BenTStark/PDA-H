DROP FUNCTION IF EXISTS root.f_check_if_table_exists (VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_table_exists (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    exist_test BOOLEAN;
    full_table_name VARCHAR(256);
    sql TEXT;
BEGIN
    full_table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    exist_test:= FALSE;
    sql:= FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT table_name) > 0 FROM information_schema.tables
        WHERE
            1 = 1
            AND table_schema = '%s'
            AND table_name = '%s';
    $Dynamic$,
    var_schema_name,
    var_table_name)::TEXT;
    EXECUTE sql INTO exist_test;
    IF exist_test AND var_drop THEN
         sql:= FORMAT($Dynamic$ DROP TABLE IF EXISTS %s;
                $Dynamic$,
                full_table_name)::TEXT;
        EXECUTE sql;
            END IF;
        RETURN exist_test;
        END;
$Body$
