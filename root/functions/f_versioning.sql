DROP FUNCTION IF EXISTS root.f_versioning (VARCHAR(256), VARCHAR(256),VARCHAR(256), VARCHAR(256));

CREATE OR REPLACE FUNCTION root.f_versioning (var_schema_name VARCHAR(256), var_table_name VARCHAR(256), var_update_columns VARCHAR(256), var_ignore_columns VARCHAR(256))
    RETURNS TEXT
    LANGUAGE plpgsql
AS $Body$
DECLARE
    sql TEXT;
    sql_check TEXT;
    
    update_columns TEXT [];
    ignore_columns TEXT [];

    increment_exist BOOLEAN DEFAULT false;

    has_update TEXT DEFAULT '';
    has_ignore TEXT DEFAULT '';
    has_increment TEXT DEFAULT '';
    update_values TEXT DEFAULT '';
    ignore_values TEXT DEFAULT '';
    increment_values TEXT DEFAULT '';
    pk_condition TEXT DEFAULT '';
    pk_values TEXT DEFAULT '';

    double_dollar VARCHAR(10);

    --table_name VARCHAR(256);
    --view_name VARCHAR(256);

    columns_info varchar(256)[][3];
    column_info varchar(256)[3];
    
    column_list TEXT DEFAULT '';
    column_list_values TEXT DEFAULT '';
    core_column_list TEXT DEFAULT '';

    set_update_columns TEXT DEFAULT '';
    conditon_pk_columns TEXT DEFAULT '';
     -- all cols  
    -- core columns mit NEW und OLD
    -- nur update_col = new.update_col; comma separtated
    -- pk condition ; AND separtetd mit NEW und OLD
    -- 
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), 'Dynamic', CHR(36)));
    --table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    --view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
    
    SELECT STRING_TO_ARRAY(var_update_columns, ',') INTO update_columns;
    SELECT STRING_TO_ARRAY(var_ignore_columns, ',') INTO ignore_columns;

    EXECUTE FORMAT($Dynamic$
    SELECT ARRAY(
    SELECT
        ARRAY[
              c.column_name
            , p.typname
            , CASE WHEN pk.attname IS NULL THEN 'N' ELSE 'Y' END]
	FROM information_schema.columns c
    LEFT JOIN pg_type p ON c.data_type::regtype::oid = p.oid
	LEFT JOIN 
        (SELECT
	        a.attname
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid
            AND a.attnum = ANY (i.indkey)
        WHERE 1 = 1
        AND i.indrelid = '%1$s.%2$s'::regclass
		AND i.indisprimary) pk 
    ON c.column_name = pk.attname
	WHERE 1 = 1
	AND c.table_schema = '%1$s'
	AND c.table_name = '%2$s'
    )$Dynamic$
    , var_schema_name
    , var_table_name )::TEXT into columns_info;

    IF var_update_columns IS NULL THEN
        has_update := FORMAT(0);
    ELSE
        has_update := FORMAT($Case$
            ,SUM(CASE 
            $Case$)::TEXT;
    END IF;

    IF var_ignore_columns IS NULL THEN
        has_ignore := FORMAT(0);
    ELSE
        has_ignore := FORMAT($Case$
            ,SUM(CASE 
            $Case$)::TEXT;
    END IF;

    increment_exist :=false;
    has_increment := FORMAT($Case$
            ,SUM(CASE 
            $Case$)::TEXT;



    FOREACH column_info SLICE 1 in ARRAY columns_info
    LOOP

        column_list := CONCAT(column_list,FORMAT($Columns$,prefix.%s$Columns$,column_info[1])::TEXT);
        raise notice 'COL: %', column_info;
        IF column_info[1]::TEXT = 'v_valid_from' THEN
            column_list_values := CONCAT(column_list_values,',now()');
        ELSEIF column_info[1]::TEXT = 'v_valid_to' THEN    
            column_list_values := CONCAT(column_list_values,FORMAT($Time$,TIMESTAMPTZ '9999-12-31 23:59:59' $Time$));
        ELSEIF column_info[1]::TEXT = 'v_last_change' THEN
            column_list_values := CONCAT(column_list_values,',now()');
        ELSEIF column_info[1]::TEXT = 'v_deleted' THEN
            column_list_values := CONCAT(column_list_values,FORMAT($Delete$,'DELETE_FLAG'$Delete$));
        ELSEIF column_info[1]::TEXT = 'v_changed_by' THEN
            column_list_values := CONCAT(column_list_values,',USER::TEXT');
        END IF;


        --raise notice '%s, %s, %s', a[1],a[2],a[3];
        IF (SELECT update_columns @> FORMAT('{%s}',column_info[1])::TEXT [ ]) THEN
            -- NEW COLUMN VALUES WILL ONLY BE UPDATED
            has_update:= CONCAT(has_update, FORMAT($Case$
            WHEN %s <> '%s'::%s THEN 1
            $Case$
            , column_info[1]
            , CONCAT(Chr(37),'s')
            , column_info[2])::TEXT);
            update_values := CONCAT(update_values,FORMAT($Values$, NEW.%s $Values$,column_info[1])::TEXT);
            column_list_values := CONCAT(column_list_values,FORMAT($Columns$,prefix.%s$Columns$,column_info[1])::TEXT);
            set_update_columns := CONCAT(set_update_columns,FORMAT($Columns$,%1$s = prefix.%1$s$Columns$,column_info[1])::TEXT);
        ELSEIF (SELECT ignore_columns @> FORMAT('{%s}',column_info[1])::TEXT [ ]) THEN
            -- NEW COLUMN VALUES WILL BE IGNORED
            has_ignore:= CONCAT(has_ignore, FORMAT($Case$
            WHEN %s <> '%s'::%s THEN 1
            $Case$
            , column_info[1]
            , CONCAT(Chr(37),'s')
            , column_info[2])::TEXT);
            ignore_values := CONCAT(ignore_values,FORMAT($Values$, NEW.%s $Values$,column_info[1])::TEXT);
            column_list_values := CONCAT(column_list_values,FORMAT($Columns$,prefix.%s$Columns$,column_info[1])::TEXT);
        ELSEIF column_info[3]::TEXT = 'N' AND column_info[1]::TEXT NOT IN ('v_valid_from','v_last_change','v_deleted','v_changed_by')  THEN
            -- NEW COLUMN VALUES LEADS TO INCREMENT 
            increment_exist := true;
            has_increment:= CONCAT(has_increment, FORMAT($Case$
            WHEN %s <> '%s'::%s THEN 1
            $Case$
            , column_info[1]
            , CONCAT(Chr(37),'s')
            , column_info[2])::TEXT);
            increment_values := CONCAT(increment_values,FORMAT($Values$, NEW.%s $Values$,column_info[1])::TEXT);
            column_list_values := CONCAT(column_list_values,FORMAT($Columns$ ,prefix.%s $Columns$,column_info[1])::TEXT);
        ELSEIF column_info[3]::TEXT = 'Y' THEN
            -- COLUMN IS PK COLUMN; EXCEPTION v_valid_to. THIS MUST BE PART OF PK AND TIMESTAMP HAS TO BE 9999-12-31
            pk_condition := CONCAT(pk_condition, FORMAT($Case$ AND %s = '%s'::%s$Case$
            , column_info[1]
            , CONCAT(Chr(37),'s')
            , column_info[2])::TEXT);
            IF column_info[1] = 'v_valid_to' THEN
                pk_values := CONCAT(pk_values,FORMAT($Values$, '9999-12-31 23:59:59'$Values$)::TEXT);
                conditon_pk_columns := CONCAT(conditon_pk_columns,FORMAT($Columns$ AND %s = '9999-12-31 23:59:59'::%s $Columns$,column_info[1],column_info[2])::TEXT);
            ELSE
                pk_values := CONCAT(pk_values,FORMAT($Values$, NEW.%s $Values$,column_info[1])::TEXT);
                column_list_values := CONCAT(column_list_values,FORMAT($Columns$,prefix.%s$Columns$,column_info[1])::TEXT);
                conditon_pk_columns := CONCAT(conditon_pk_columns,FORMAT($Columns$ AND %1$s = prefix.%1$s$Columns$,column_info[1])::TEXT);
            END IF;
        END IF;
    END LOOP;

    IF var_update_columns IS NOT NULL THEN
        has_update:= CONCAT(has_update, FORMAT($Case$ ELSE 0 END) AS has_update$Case$)::TEXT);
    END IF;

    IF var_ignore_columns IS NOT NULL THEN
        has_ignore:= CONCAT(has_ignore, FORMAT($Case$ ELSE 0 END) AS has_ignore$Case$)::TEXT);
    END IF;

    IF increment_exist THEN
        has_increment:= CONCAT(has_increment, FORMAT($Case$ ELSE 0 END) AS has_increment$Case$)::TEXT);
    ELSE
        has_increment := FORMAT(0);
    END IF;

    ------------------------
    -- sql_check SHOULD LOOK LIKE THIS:
    -------------------------
    /*
    sql_check:= FORMAT($Check$
        SELECT 
            count(*) as cnt
            , SUM(CASE 
                WHEN ignore_col <> '%s'
                THEN 1 ELSE 0 END) AS has_ignore
            , SUM(CASE 
                WHEN update_col <> '%s'
                THEN 1 ELSE 0 END) AS has_update
            , SUM(CASE 
                WHEN normal_col <> '%s'
                THEN 1 ELSE 0 END) AS has_increment
        FROM root.tv_test_table 
        where 1=1
        AND id = %s
        and v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
        $Check$
        , NEW.ignore_col
        , NEW.update_col 
        , NEW.normal_col
        , NEW.id)::TEXT;
    */
    ----------------------------------
    sql_check:= FORMAT($Check$
        %s
        SELECT 
            count(*) as cnt
            %s
            %s
            %s
        FROM root.tv_test_table 
        where 1=1
        %s
        %s
        %s
        %s
        %s
        %s
        $Check$
        , double_dollar
        , has_ignore
        , has_update
        , has_increment
        , pk_condition
        , double_dollar
        , ignore_values
        , update_values
        , increment_values
        , pk_values)::TEXT;

    sql:= FORMAT($Dynamic$
        IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN
        
        EXECUTE FORMAT(%1$s)::TEXT INTO cnt,has_ignore,has_update,has_increment;

        raise notice 'cnt: %%',cnt;
        raise notice 'has_ignore: %%',has_ignore;
        raise notice 'has_update: %%',has_update;
        raise notice 'has_increment: %%',has_increment;
        raise notice 'UPDATE/INSERT';
        IF cnt = 0 THEN
            -- Primary Key not existing
            INSERT INTO %2$s.%3$s (%4$s) VALUES (%5$s);
        ELSE
            -- Primary Key exisiting
            IF has_increment > 0 THEN
                -- column creates increment, then ignore and update columns are handeled normal just like increment columns.
                UPDATE %2$s.%3$s SET v_valid_to = now(), v_last_change = now(),v_changed_by = USER::TEXT WHERE 1=1 %8$s;
                INSERT INTO %2$s.%3$s (%4$s) VALUES (%5$s);
            ELSE
                IF has_update > 0 THEN
                    UPDATE %2$s.%3$s SET v_last_change=now(),v_changed_by = USER::TEXT %7$s WHERE 1=1 %8$s;
                END IF;
            END IF;
        END IF;
    ELSEIF TG_OP = 'DELETE' THEN
        raise notice 'DELETE';

        UPDATE %2$s.%3$s SET v_valid_to = now(), v_last_change=now() ,v_changed_by = USER::TEXT WHERE 1=1 %9$s;
        INSERT INTO %2$s.%3$s (%4$s) VALUES (%6$s);
    END IF;
    $Dynamic$
    , sql_check
    , var_schema_name
    , var_table_name
    , SUBSTRING(REPLACE(column_list,'prefix.',''),2)
    , SUBSTRING(REPLACE(REPLACE(column_list_values,'prefix.','NEW.'),'DELETE_FLAG','N'),2)
    , SUBSTRING(REPLACE(REPLACE(column_list_values,'prefix.','OLD.'),'DELETE_FLAG','Y'),2)
    , REPLACE(set_update_columns,'prefix.','NEW.')
    , REPLACE(conditon_pk_columns,'prefix.','NEW.')
    , REPLACE(conditon_pk_columns,'prefix.','OLD.'))::TEXT;

    RETURN sql;
   
END;
$Body$

    

