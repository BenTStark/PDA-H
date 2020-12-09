--DROP VIEW root.vd_test_table;
--DROP VIEW root.vv_test_table;
--DROP TABLE root.tv_test_table;
SELECT
    root.f_drop_config ('root',
        'tv_test_table',
        NULL);

CREATE TABLE IF NOT EXISTS root.tv_test_table (
        id SERIAL NOT NULL,
        info TEXT,
        normal_col TEXT,
        update_col TEXT,
        ignore_col TEXT,
        v_valid_from TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_valid_to TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '9999-12-31 23:59:59',
        v_last_change TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_deleted VARCHAR(1) NOT NULL DEFAULT 'N',
        v_changed_by TEXT NOT NULL DEFAULT 'n/a',
        PRIMARY KEY (id,v_valid_to)
);

SELECT root.f_config ( 'root', 'tv_test_table' ,  true,  'update_col',  'ignore_col',  false,  false);
/*
CREATE OR REPLACE VIEW root.vv_test_table AS
SELECT
      id
    , info
    , normal_col
    , update_col
    , ignore_col
    , v_valid_from 
    , v_valid_to 
    , v_last_change
    , v_deleted
    , v_changed_by
FROM root.tv_test_table
WHERE 1=1
AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
AND v_deleted = 'N'
;

CREATE OR REPLACE VIEW root.vd_test_table AS
SELECT
      id
    , info
    , normal_col
    , update_col
    , ignore_col
    , v_valid_from 
    , v_valid_to 
    , v_last_change
    , v_deleted
    , v_changed_by
FROM root.tv_test_table
WHERE 1=1
AND v_valid_to = TIMESTAMPTZ '9999-12-31 23:59:59'
;
*/