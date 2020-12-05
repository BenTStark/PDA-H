DROP FUNCTION IF EXISTS root.f_check_if_index_exists (VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_index_exists (var_schema_name VARCHAR(256), var_index_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    exist_test BOOLEAN;
    sql TEXT;
BEGIN
    exist_test:= FALSE;
    sql:= FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT indexname) > 0 FROM pg_indexes
        WHERE
            1 = 1
            AND schemaname = '%s'
            AND indexname = '%s';
    $Dynamic$,
    var_schema_name,
    var_index_name)::TEXT;
    EXECUTE sql INTO exist_test;
    IF exist_test AND var_drop THEN
         sql:= FORMAT($Dynamic$ DROP INDEX IF EXISTS %s;
                $Dynamic$,
                var_index_name)::TEXT;
        EXECUTE sql;
            END IF;
        RETURN exist_test;
        END;
$Body$
