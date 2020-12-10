DROP FUNCTION IF EXISTS root.f_check_if_sequence_exists (VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_sequence_exists (var_schema_name VARCHAR(256), var_sequence_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    exist_test BOOLEAN;
    full_sequence_name TEXT;
    sql TEXT;
BEGIN
    exist_test:= FALSE;
    full_sequence_name:= FORMAT('%s.%s',var_schema_name, var_sequence_name);
    sql:= FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT p.relname) > 0 FROM pg_class p
        INNER JOIN pg_namespace n ON p.relnamespace = n.OID
        WHERE 1 = 1
        AND n.nspname = '%s'
        AND p.relname = '%s';
    $Dynamic$,
    var_schema_name,
    var_sequence_name)::TEXT;
    EXECUTE sql INTO exist_test;
    IF exist_test AND var_drop THEN
        raise notice 'DROPING SEQUENCE: %', full_sequence_name;
        sql:= FORMAT($Dynamic$ DROP SEQUENCE IF EXISTS %s;
            $Dynamic$,
            full_sequence_name)::TEXT;
        EXECUTE sql;
    END IF;
    RETURN exist_test;
END;
$Body$
