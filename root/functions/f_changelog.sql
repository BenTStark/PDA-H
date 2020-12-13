DROP FUNCTION IF EXISTS root.f_changelog (VARCHAR(256), VARCHAR(256));

CREATE OR REPLACE FUNCTION root.f_changelog (var_schema_name VARCHAR(256), var_table_name VARCHAR(256))
    RETURNS TEXT
    LANGUAGE plpgsql
AS $Body$
DECLARE
    columns TEXT;
    prefix_columns TEXT;
    columns_datatype TEXT;
    sql TEXT;
    double_dollar VARCHAR(10);
    sql_changegroup TEXT;
    sql_changelog TEXT;
    context TEXT;
    timeseries_trigger_name TEXT;
    timeseries_view_name TEXT;
    versioning_trigger_name TEXT;
    versioning_view_name TEXT;
    full_table_name TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), 'Body', CHR(36)));
    full_table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    versioning_trigger_name:= FORMAT('t_instead_of_vv_%s', var_table_name);
    versioning_view_name:= FORMAT('vv_%s', var_table_name);
    timeseries_trigger_name:= FORMAT('t_instead_of_v_%s', var_table_name);
    timeseries_view_name:= FORMAT('v_%s', var_table_name);
    
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CHR(39) || c.column_name::TEXT ||CHR(39), ',')
            FROM information_schema.columns c
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I' 
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO columns;
    
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('prefix.' || c.column_name::TEXT || '::TEXT', ',')
            FROM information_schema.columns c
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I'
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO prefix_columns;
    
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CHR(39) || p.typname::TEXT || CHR(39), ',')
        FROM information_schema.columns c
        LEFT JOIN pg_type p ON c.data_type::regtype::oid = p.oid
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I' 
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO columns_datatype;
    
    
    context:= NULL;
    IF root.f_check_if_trigger_exists (var_schema_name,
            timeseries_trigger_name,
            timeseries_view_name,
            FALSE) THEN
        context:= CONCAT_WS(',',context,'timeseries');
    END IF;
    IF root.f_check_if_trigger_exists (var_schema_name,
            versioning_trigger_name,
            versioning_view_name,
            FALSE) THEN
        context:= CONCAT_WS(',',context,'versioning');
    END IF;
    
    sql_changegroup:= FORMAT($Dynamic$ 
    INSERT INTO root.changegroup (userid, created_at, operation, context)
    SELECT
        USER, NOW(), TG_OP, '%s';
    $Dynamic$
    , context)::TEXT;

    sql_changelog:= FORMAT($Dynamic$ 
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%1$s' AS table_name, UNNEST(ARRAY [ %2$s ]) AS column_name, UNNEST(ARRAY [ %3$s ]) AS column_data_type, UNNEST(ARRAY [ %4$s ]) AS old_value, UNNEST(ARRAY [ %5$s ]) AS new_value;
        RETURN NEW;
    ELSEIF TG_OP = 'INSERT' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%1$s' AS table_name, UNNEST(ARRAY [ %2$s ]) AS column_name, UNNEST(ARRAY [ %3$s ]) AS column_data_type, NULL AS old_value, UNNEST(ARRAY [ %5$s ]) AS new_value;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%1$s' AS table_name, UNNEST(ARRAY [ %2$s ]) AS column_name, UNNEST(ARRAY [ %3$s ]) AS column_data_type, UNNEST(ARRAY [ %4$s ]) AS old_value, NULL AS new_value;
        RETURN OLD;
    END IF;
    $Dynamic$
    , full_table_name
    , columns
    , columns_datatype
    , REPLACE(prefix_columns, 'prefix.', 'OLD.')
    , REPLACE(prefix_columns, 'prefix.', 'NEW.'))::TEXT;
    
    sql:= CONCAT_WS(CHR(10), sql_changegroup, sql_changelog);

    RETURN sql;
END;
$Body$
