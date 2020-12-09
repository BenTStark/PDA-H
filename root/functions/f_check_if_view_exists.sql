DROP FUNCTION IF EXISTS root.f_check_if_view_exists (VARCHAR(256), VARCHAR(256), BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_check_if_view_exists (var_schema_name VARCHAR(256), var_view_name VARCHAR(256), var_drop BOOLEAN)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $Body$
DECLARE
    exist_test BOOLEAN;
    view_name VARCHAR(256);
    sql TEXT;
BEGIN
    view_name:= FORMAT('%s.%s', var_schema_name, var_view_name);
    exist_test:= FALSE;
    EXECUTE FORMAT($Dynamic$
        SELECT
            COUNT(DISTINCT table_name) > 0 FROM information_schema.views
        WHERE 1 = 1
        AND table_schema = '%s'
        AND table_name = '%s';
    $Dynamic$,
    var_schema_name,
    var_view_name) INTO exist_test;
    IF exist_test AND var_drop THEN
        EXECUTE FORMAT($Dynamic$ DROP VIEW IF EXISTS %s;
                $Dynamic$,
                view_name);
    END IF;
    RETURN exist_test;
END;
$Body$
