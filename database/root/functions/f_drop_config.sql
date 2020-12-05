DROP FUNCTION IF EXISTS root.f_drop_config (VARCHAR(256), VARCHAR(256), TEXT);

CREATE OR REPLACE FUNCTION root.f_drop_config (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), object_string TEXT)
    RETURNS void
    LANGUAGE plpgsql
AS $Body$
DECLARE
    table_name VARCHAR(256);
    view_name VARCHAR(256);
    view_short_name VARCHAR(256);
    trigger_short_name VARCHAR(256);
    function_short_name VARCHAR(256);
    object_array TEXT [ ];
    sql TEXT;
BEGIN
    SELECT
        STRING_TO_ARRAY(object_string, ',') INTO object_array;
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
    view_short_name:= FORMAT('v_%s', var_table_name);
    trigger_short_name:= FORMAT('t_instead_of_v_%s', var_table_name);
    -- DROP Trigger
    IF (
            SELECT
                object_array @> '{trigger}'::TEXT [ ]) THEN
        ELSE
            PERFORM
                root.f_check_if_trigger_exists (var_schema_name,
                    trigger_short_name,
                    view_name,
                    TRUE);
    END IF;
    -- DROP View
    IF (
            SELECT
                object_array @> '{view}'::TEXT [ ]) THEN
        ELSE
            PERFORM
                root.f_check_if_view_exists (var_schema_name,
                    view_short_name,
                    TRUE);
    END IF;
    -- DROP functions;
    IF (
            SELECT
                object_array @> '{function}'::TEXT [ ]) THEN
        ELSE
            function_short_name:= FORMAT('f_%s_changelog', var_table_name);
        PERFORM
            root.f_check_if_function_exists (var_schema_name,
                function_short_name,
                TRUE);
        function_short_name:= FORMAT('f_%s_timeseries', var_table_name);
        PERFORM
            root.f_check_if_function_exists (var_schema_name,
                function_short_name,
                TRUE);
        function_short_name:= FORMAT('f_%s_timeseries_afterburner', var_table_name);
        PERFORM
            root.f_check_if_function_exists (var_schema_name,
                function_short_name,
                TRUE);
    END IF;
    --DROP Triggerfunction
    IF (
            SELECT
                object_array @> '{triggerfunction}'::TEXT [ ]) THEN
        ELSE
            function_short_name:= FORMAT('tf_instead_of_v_%s', var_table_name);
        PERFORM
            root.f_check_if_function_exists (var_schema_name,
                function_short_name,
                TRUE);
    END IF;
    -- DROP Table
    IF (
            SELECT
                object_array @> '{table}'::TEXT [ ]) THEN
        ELSE
            PERFORM
                root.f_check_if_table_exists (var_schema_name,
                    var_table_name,
                    TRUE);
    END IF;
END;
$Body$
