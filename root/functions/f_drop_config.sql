DROP FUNCTION IF EXISTS root.f_drop_config (VARCHAR(256), VARCHAR(256), TEXT);

CREATE OR REPLACE FUNCTION root.f_drop_config (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), object_string TEXT)
-- object array contains exceptions
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
    prefixes VARCHAR(2)[] := array['v', 'vv', 'vd'];
    prefix VARCHAR(2);
    triggers VARCHAR(20)[] := array['after','before', 'instead_of'];
    trigger VARCHAR(20);
    sql TEXT;
BEGIN
    SELECT STRING_TO_ARRAY(object_string, ',') INTO object_array;
    IF SUBSTRING(var_table_name,1,3) = 'tv_' THEN
        table_name:= SUBSTRING(var_table_name,4);
    ELSE
        table_name:= var_table_name;
    END IF;

    
    -- DROP Trigger
    IF (
            SELECT
                object_array @> '{trigger}'::TEXT [ ]) THEN
    ELSE
        
        FOREACH prefix IN ARRAY prefixes
        LOOP
            FOREACH trigger IN ARRAY triggers
            LOOP
                trigger_short_name:= FORMAT('t_%s_%s_%s', trigger, prefix, table_name);
                raise notice 'drop trigger: %s', trigger_short_name;
                view_name:= FORMAT('%s.%s_%s', var_schema_name, prefix, table_name);
                PERFORM
                    root.f_check_if_trigger_exists (var_schema_name,
                        trigger_short_name,
                        view_name,
                        TRUE);
                PERFORM
                    root.f_check_if_trigger_exists (var_schema_name,
                        trigger_short_name,
                        var_table_name,
                        TRUE);
            END LOOP;
        END LOOP;
    END IF;
    --DROP Triggerfunction
    IF (
            SELECT
                object_array @> '{triggerfunction}'::TEXT [ ]) THEN
     ELSE
        FOREACH prefix IN ARRAY prefixes
        LOOP
            FOREACH trigger IN ARRAY triggers
            LOOP
                function_short_name:= FORMAT('tf_%s_%s_%s',trigger, prefix, table_name);
                raise notice 'drop triggerfunction: %s', function_short_name;
                PERFORM
                    root.f_check_if_function_exists (var_schema_name,
                        function_short_name,
                        TRUE);
            END LOOP;
        END LOOP;
    END IF;
    -- DROP View
    IF (
            SELECT
                object_array @> '{view}'::TEXT [ ]) THEN
     ELSE
        FOREACH prefix IN ARRAY prefixes
        LOOP
            view_short_name:= FORMAT('%s_%s', prefix, table_name);
            raise notice 'drop view: %s', view_short_name;
            PERFORM 
                root.f_check_if_view_exists (var_schema_name,
                    view_short_name,
                    TRUE);
        END LOOP;
    END IF;
    -- DROP functions;
    -- TODO: das hier weg weil ich das alles über trigger functions löse?
    IF (
            SELECT
                object_array @> '{function}'::TEXT [ ]) THEN
    ELSE
        raise notice 'drop functions';
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
    -- DROP Table
    IF (
            SELECT
                object_array @> '{table}'::TEXT [ ]) THEN
        ELSE
            raise notice 'drop table: %s', var_table_name;
            PERFORM
                root.f_check_if_table_exists (var_schema_name,
                    var_table_name,
                    TRUE);
    END IF;
END;
$Body$
