DROP FUNCTION IF EXISTS root.f_changelog (VARCHAR(256), VARCHAR(256));

CREATE OR REPLACE FUNCTION root.f_changelog (var_schema_name VARCHAR(256), var_table_name VARCHAR(256))
    RETURNS void
    LANGUAGE plpgsql
AS $Body$
DECLARE
    columns TEXT;
    columns2 TEXT;
    columns_datatype TEXT;
    sql TEXT;
    double_dollar VARCHAR(10);
    sql_tf TEXT;
    sql_changegroup TEXT;
    sql_changelog TEXT;
    context TEXT;
    trigger_name TEXT;
    view_name TEXT;
    table_name TEXT;
    functions TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), 'Body', CHR(36)));
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    trigger_name:= FORMAT('t_instead_of_v_%s', var_table_name);
    view_name:= FORMAT('v_%s', var_table_name);
    
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
            STRING_AGG('NEW.' || c.column_name::TEXT || '::TEXT', ',')
            FROM information_schema.columns c
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I'
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO columns2;
    
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CHR(39) || c.data_type::TEXT || CHR(39), ',')
            FROM information_schema.columns c
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I' $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO columns_datatype;
    
    IF root.f_check_if_trigger_exists (var_schema_name,
            trigger_name,
            view_name,
            FALSE) THEN
        context:= 'timeseries';
    ELSE
        context:= NULL;
    END IF;
    
    sql_changegroup:= FORMAT($Dynamic$ 
    INSERT INTO changegroup (userid, created_at, operation, context)
    SELECT
        USER, NOW(), TG_OP, '%s';
    $Dynamic$
    , context)::TEXT;

    sql_changelog:= FORMAT($Dynamic$ 
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%s' AS table_name, UNNEST(ARRAY [ %s ]) AS column_name, UNNEST(ARRAY [ %s ]) AS column_data_type, UNNEST(ARRAY [ %s ]) AS old_value, UNNEST(ARRAY [ %s ]) AS new_value;
        RETURN NEW;
    ELSEIF TG_OP = 'INSERT' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%s' AS table_name, UNNEST(ARRAY [ %s ]) AS column_name, UNNEST(ARRAY [ %s ]) AS column_data_type, NULL AS old_value, UNNEST(ARRAY [ %s ]) AS new_value;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        INSERT INTO root.changelog (changegroup_id, table_name, column_name, column_data_type, old_value, new_value)
        SELECT
            CURRVAL(PG_GET_SERIAL_SEQUENCE('changegroup', 'changegroup_id')), '%s' AS table_name, UNNEST(ARRAY [ %s ]) AS column_name, UNNEST(ARRAY [ %s ]) AS column_data_type, UNNEST(ARRAY [ %s ]) AS old_value, NULL AS new_value;
        RETURN OLD;
    END IF;
    $Dynamic$
    , table_name
    , columns
    , columns_datatype
    , REPLACE(columns2, 'NEW', 'OLD')
    , columns2
    , table_name
    , columns
    , columns_datatype
    , columns2
    , table_name
    , columns
    , columns_datatype
    , REPLACE(columns2, 'NEW', 'OLD'))::TEXT;
    
    functions:= CONCAT_WS(CHR(10), sql_changegroup, sql_changelog);

    sql_tf:= FORMAT($Dynamic$ 
        CREATE OR REPLACE FUNCTION %s.tf_after_%s ()
        RETURNS TRIGGER
        LANGUAGE 'plpgsql'
        AS %s
        BEGIN
            %s RETURN NULL;
        END %s;
        $Dynamic$
        , var_schema_name
        , var_table_name
        , double_dollar
        , functions
        , double_dollar)::TEXT;
    EXECUTE sql_tf;
END;
$Body$
