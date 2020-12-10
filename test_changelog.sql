SELECT
    root.f_drop_config ('root',
        'test_changelog',
        NULL);

CREATE TABLE IF NOT EXISTS root.test_changelog (
        id SERIAL NOT NULL,
        info TEXT,
        normal_col TEXT,
        update_col TEXT,
        ignore_col TEXT,
        --v_valid_from TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        --v_valid_to TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '9999-12-31 23:59:59',
        --v_last_change TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        --v_deleted VARCHAR(1) NOT NULL DEFAULT 'N',
        --v_changed_by TEXT NOT NULL DEFAULT 'n/a',
        PRIMARY KEY (id)--,v_valid_to)
);

SELECT root.f_config ( 'root', 'test_changelog' ,  false,  NULL,  NULL,  false,  true);