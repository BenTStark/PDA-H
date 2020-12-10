DROP FUNCTION IF EXISTS root.f_check_if_trigger_exists (VARCHAR(256), VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_trigger_exists (var_schema_name VARCHAR(256), var_trigger_name VARCHAR(256), var_target_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    trigger_name VARCHAR(256);
    exist_test BOOLEAN;
    sql TEXT;
BEGIN
    exist_test:= FALSE;
    sql:= FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT trigger_name) > 0 FROM information_schema.triggers
        WHERE 1 = 1
        AND trigger_schema = '%s'
        AND trigger_name = '%s';
    $Dynamic$,
    var_schema_name,
    var_trigger_name)::TEXT;
    EXECUTE sql INTO exist_test;
    IF exist_test AND var_drop THEN
        raise notice 'DROPING TRIGGER: % ON %', var_trigger_name,var_target_name;
        sql:= FORMAT($Dynamic$ DROP TRIGGER IF EXISTS %s ON %s;
            $Dynamic$,
            var_trigger_name,
            var_target_name)::TEXT;
        EXECUTE sql;
    END IF;
    RETURN exist_test;
END;
$Body$
