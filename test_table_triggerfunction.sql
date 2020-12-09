CREATE OR REPLACE FUNCTION root.tf_instead_of_vv_test_table ()
RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $Body$
DECLARE
    sql TEXT;
    cnt INT DEFAULT 0;
    has_ignore INT DEFAULT 0;
    has_update INT DEFAULT 0;
    has_normal_col INT DEFAULT 0;

BEGIN
/* 
    sql:= FORMAT($Dynamic$
    SELECT count(*) as cnt,CASE 
        WHEN ignore_col <> NEW.ignore_col
        THEN 1 ELSE 0 END AS has_ignore
        , CASE 
        WHEN update_col <> NEW.update_col 
        THEN 1 ELSE 0 END AS has_update
        , CASE 
        WHEN normal_col <> NEW.normal_col
        THEN 1 ELSE 0 END AS has_normal_col
    FROM root.tv_test_table where 1=1
    and v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
    $Dynamic$)::TEXT;
    EXECUTE sql INTO cnt,has_ignore,has_update,has_normal_col;
*/
    IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN
        sql:= FORMAT($Dynamic$
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
                    THEN 1 ELSE 0 END) AS has_normal_col
            FROM root.tv_test_table 
            where 1=1
            AND id = %s
            and v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
            $Dynamic$
            , NEW.ignore_col
            , NEW.update_col 
            , NEW.normal_col
            , NEW.id)::TEXT;
        EXECUTE sql INTO cnt,has_ignore,has_update,has_normal_col;

        raise notice 'cnt: %',cnt;
        raise notice 'has_ignore: %',has_ignore;
        raise notice 'has_update: %',has_update;
        raise notice 'has_normal_col: %',has_normal_col;
        raise notice 'UPDATE/INSERT';
        IF cnt = 0 THEN
            -- Primary Key not existing
            INSERT INTO root.tv_test_table (id,info,normal_col,update_col,ignore_col,v_valid_from,v_valid_to,v_last_change,v_deleted,v_changed_by) VALUES (NEW.id,NEW.info,NEW.normal_col,NEW.update_col,NEW.ignore_col,now(),TIMESTAMPTZ '9999-12-31 23:59:59',now(),'N','Me');
        ELSE
            -- Primary Key exisiting
            IF has_normal_col > 0 THEN
                -- column creates increment, then ignore and update columns are handeled normal just like increment columns.
                UPDATE root.tv_test_table SET v_valid_to = now(), v_last_change = now() WHERE 1=1 AND id = NEW.id AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59';
                INSERT INTO root.tv_test_table (id,info,normal_col,update_col,ignore_col,v_valid_from,v_valid_to,v_last_change,v_deleted,v_changed_by) VALUES (NEW.id,NEW.info,NEW.normal_col,NEW.update_col,NEW.ignore_col,now(),TIMESTAMPTZ '9999-12-31 23:59:59',now(),'N','Me');
            ELSE
                IF has_update > 0 THEN
                    UPDATE root.tv_test_table SET v_last_change=now(), update_col = NEW.update_col WHERE 1=1 AND id = NEW.id AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59';
                END IF;
            END IF;
        END IF;
    ELSEIF TG_OP = 'DELETE' THEN
        raise notice 'DELETE';

        UPDATE root.tv_test_table SET v_valid_to = now(), v_last_change=now() WHERE 1=1 AND id = OLD.id AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59';
        INSERT INTO root.tv_test_table (id,info,normal_col,update_col,ignore_col,v_valid_from,v_valid_to,v_last_change,v_deleted,v_changed_by) VALUES (OLD.id,OLD.info,OLD.normal_col,OLD.update_col,OLD.ignore_col,now(),TIMESTAMPTZ '9999-12-31 23:59:59',now(),'Y','Me');
    END IF;

    RETURN NULL;
END $Body$;

          