DROP FUNCTION IF EXISTS root.f_config ( VARCHAR(256),  VARCHAR(256),  BOOLEAN,  VARCHAR(256),  VARCHAR(256),  BOOLEAN,  BOOLEAN);

CREATE OR REPLACE FUNCTION root.f_config (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), var_versioning BOOLEAN, var_update_columns VARCHAR(256), var_ignore_columns VARCHAR(256), var_timeseries BOOLEAN, var_changelog BOOLEAN)
    RETURNS void
    LANGUAGE plpgsql
AS $Body$
DECLARE
    table_name VARCHAR(256);
    var_table_name_ext VARCHAR(256);
    view_name VARCHAR(256);
    versionised_view_name VARCHAR(256);
    versionised_delete_view_name VARCHAR(256);
    double_dollar VARCHAR(10);
    columns TEXT;
    new_columns TEXT;
    values_placeholder TEXT;
    sql_tf TEXT;
    sql_t TEXT;
    sql_v TEXT;
    functions TEXT; --TODO: DELETE After refactoring
    function_body TEXT;
    sql TEXT;
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), 'Body', CHR(36)));
    table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    IF var_versioning THEN
        view_name:= FORMAT('%s.vt_%s', var_schema_name, SUBSTRING(var_table_name,4));
        var_table_name_ext := SUBSTRING(var_table_name,4);
    ELSE
        view_name:= FORMAT('%s.vt_%s', var_schema_name, var_table_name);
        var_table_name_ext := var_table_name;
    END IF;
    versionised_view_name:= FORMAT('%s.vv_%s', var_schema_name, SUBSTRING(var_table_name,4));
    versionised_delete_view_name:= FORMAT('%s.vd_%s', var_schema_name, SUBSTRING(var_table_name,4));
    -- table columns
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(c.column_name, ',')
            FROM information_schema.columns c
        WHERE 1 = 1
        AND table_schema = '%I'
        AND table_name = '%I' 
        $Dynamic$
        , var_schema_name
        , var_table_name)::TEXT;
    EXECUTE sql INTO columns;
    -- table columns with NEW Prefix
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG(CONCAT('NEW.', c.column_name), ',')
            FROM information_schema.columns c
        WHERE 1 = 1
            AND table_schema = '%I'
            AND table_name = '%I' 
            $Dynamic$
            , var_schema_name
            , var_table_name)::TEXT;
    EXECUTE sql INTO new_columns;
    -- Value placeholder for each column
    sql:= FORMAT($Dynamic$
        SELECT
            STRING_AGG('%s', ',')
            FROM information_schema.columns c
        WHERE 1 = 1
            AND table_schema = '%I'
            AND c.table_name = '%I'
            $Dynamic$
            , CONCAT(CHR(37), CHR(76))
            , var_schema_name
            , var_table_name)::TEXT;
    EXECUTE sql INTO values_placeholder;

    PERFORM
        root.f_drop_config (var_schema_name,
            var_table_name,
            'table');

    IF var_versioning THEN
        -- FIRST STEP: CREATE VIEWS
        -- VERSIONISED VIEW
        sql_v:= FORMAT($Dynamic$ 
            CREATE OR REPLACE VIEW %s
            AS
            SELECT
                %s FROM %s
            WHERE 1 = 1
            AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
            AND v_deleted = 'N'
            $Dynamic$
            , versionised_view_name
            , columns
            , table_name)::TEXT;
        raise notice 'CREATE %', versionised_view_name;
        EXECUTE sql_v;
        -- VERSIONISED DELETE VIEW
        sql_v:= FORMAT($Dynamic$ 
            CREATE OR REPLACE VIEW %s
            AS
            SELECT
                %s FROM %s
            WHERE 1 = 1
            AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
            $Dynamic$
            , versionised_delete_view_name
            , columns
            , table_name)::TEXT;
        raise notice 'CREATE %', versionised_delete_view_name;
        EXECUTE sql_v;
        
        -- CREATE FUNCTION STRING TO HANDLE VERSIONING. STRING WILL BE IMPLEMENTED INTO TRIGGER FUNCTION
        SELECT root.f_versioning(var_schema_name,var_table_name,var_update_columns,var_ignore_columns) INTO function_body;
        -- CREATE TRIGGER FUNCTION SQL QUERY
        sql_tf:= FORMAT($Dynamic$ 
            CREATE OR REPLACE FUNCTION %s.tf_instead_of_vv_%s ()
            RETURNS TRIGGER
            LANGUAGE 'plpgsql'
            AS %s
            DECLARE
                sql TEXT;
                cnt INT DEFAULT 0;
                has_ignore INT DEFAULT 0;
                has_update INT DEFAULT 0;
                has_increment INT DEFAULT 0;
            BEGIN
                %s 
                RETURN NULL;
            END; %s
            $Dynamic$
            , var_schema_name
            , SUBSTRING(var_table_name,4)
            , double_dollar
            , function_body
            , double_dollar)::TEXT;
        
        -- CREATE TRIGGER SQL QUERY
        sql_t:= FORMAT($Dynamic$ 
            CREATE TRIGGER t_instead_of_vv_%s INSTEAD OF INSERT
            OR
            UPDATE
            OR 
            DELETE
            ON %s FOR EACH ROW EXECUTE PROCEDURE %s.tf_instead_of_vv_%s ();
            $Dynamic$
            , SUBSTRING(var_table_name,4)
            , versionised_view_name
            , var_schema_name
            , SUBSTRING(var_table_name,4))::TEXT;
        -- EXECUTE STATMENTS
        raise notice 'CREATE tf_instead_of_vv_%', SUBSTRING(var_table_name,4);
        EXECUTE sql_tf;
        raise notice 'CREATE t_instead_of_vv_%', SUBSTRING(var_table_name,4);
        EXECUTE sql_t;

    END IF;   
    
    
    IF var_timeseries THEN
        SELECT root.f_timeseries(var_schema_name,var_table_name,var_versioning) INTO function_body;
        
        sql_v:= FORMAT($Dynamic$ 
            CREATE OR REPLACE VIEW %s
            AS
            SELECT
                %s FROM %s
            WHERE 1 = 1
            AND valid_from <= NOW()
            AND valid_to > NOW() 
            $Dynamic$
            , view_name
            , columns
            , table_name)::TEXT;
        raise notice 'CREATE %', view_name;
        EXECUTE sql_v;
 
        sql_tf:= FORMAT($Dynamic$ 
            CREATE OR REPLACE FUNCTION %s.tf_instead_of_vt_%s ()
            RETURNS TRIGGER
            LANGUAGE 'plpgsql'
            AS %s
            DECLARE
                insert_sql TEXT;
                insert_sql_dublicate TEXT [];
                insert_sql_update  TEXT [];
            BEGIN
                %s 
            RETURN NULL;
            END; %s
            $Dynamic$
            , var_schema_name
            , var_table_name_ext
            , double_dollar
            , function_body
            , double_dollar)::TEXT;
            
        sql_t:= FORMAT($Dynamic$ 
            CREATE TRIGGER t_instead_of_vt_%s INSTEAD OF INSERT
            OR
            UPDATE
            ON %s FOR EACH ROW EXECUTE PROCEDURE %s.tf_instead_of_vt_%s ();
            $Dynamic$
            , var_table_name_ext
            , view_name
            , var_schema_name
            , var_table_name_ext)::TEXT;
        raise notice 'CREATE tf_instead_of_vt_%', var_table_name_ext;
        EXECUTE sql_tf;
        raise notice 'CREATE t_instead_of_vt_%', var_table_name_ext;
        EXECUTE sql_t;
    END IF;

    IF var_changelog THEN
    
    SELECT root.f_changelog(var_schema_name,var_table_name) INTO function_body;
    -- CREATE TRIGGER FUNCTION SQL QUERY
    sql_tf:= FORMAT($Dynamic$ 
        CREATE OR REPLACE FUNCTION %s.tf_after_%s ()
        RETURNS TRIGGER
        LANGUAGE 'plpgsql'
        AS %s
        BEGIN
            %s 
            RETURN NULL;
        END %s;
        $Dynamic$
        , var_schema_name
        , var_table_name
        , double_dollar
        , function_body
        , double_dollar)::TEXT;
    
    -- CREATE TRIGGER SQL QUERY
    sql_t:= FORMAT($Dynamic$ 
        CREATE TRIGGER t_after_%s AFTER INSERT
        OR DELETE
        OR
        UPDATE
            ON %s FOR EACH ROW EXECUTE PROCEDURE %s.tf_after_%s ();
        $Dynamic$
        , var_table_name
        , table_name
        , var_schema_name
        , var_table_name)::TEXT;

    -- EXECUTE STATMENTS
    raise notice 'CREATE tf_after_%', var_table_name;
    EXECUTE sql_tf;
    raise notice 'CREATE t_after_%', var_table_name;
    EXECUTE sql_t;
    END IF;
END;
$Body$
