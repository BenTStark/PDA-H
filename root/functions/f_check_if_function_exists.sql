DROP FUNCTION IF EXISTS root.f_check_if_function_exists (VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_function_exists (var_schema_name VARCHAR(256), var_function_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    exist_test BOOLEAN;
    r record;
    args TEXT;
    ausgabe TEXT;
    sql TEXT;
BEGIN
    exist_test:= FALSE;
    sql:= FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT p.proname) > 0 FROM pg_proc p
        INNER JOIN pg_namespace n ON p.pronamespace = n.OID
        WHERE 1 = 1
        AND n.nspname = '%s'
        AND p.proname = '%s';
    $Dynamic$,
    var_schema_name,
    var_function_name)::TEXT;
    EXECUTE sql INTO exist_test;
    IF exist_test AND var_drop THEN
        sql:= FORMAT($Dynamic$
            SELECT
                pg_catalog.PG_GET_FUNCTION_IDENTITY_ARGUMENTS(p.OID) AS args
            FROM
                pg_proc p
            INNER JOIN pg_namespace n ON p.pronamespace = n.OID
            WHERE 1 = 1
            AND n.nspname = '%s'
            AND p.proname = '%s' 
            $Dynamic$,
            var_schema_name, var_function_name)::TEXT;
        FOR r IN EXECUTE sql
        LOOP
            sql:= FORMAT($Dynamic$ 
                DROP FUNCTION IF EXISTS %s.%s (%s);
                $Dynamic$,
                var_schema_name,
                var_function_name,
                r.args)::TEXT;
            EXECUTE sql;
        END LOOP;
    END IF;
    RETURN exist_test;
END;
$Body$
