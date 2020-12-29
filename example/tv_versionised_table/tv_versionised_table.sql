SELECT
    root.f_drop_config ('example',
        'tv_versionised_table',
        NULL);

CREATE TABLE IF NOT EXISTS example.tv_versionised_table (
        id SERIAL NOT NULL,
        normal_col TEXT NOT NULL DEFAULT 'normal',
        update_col TEXT,
        ignore_col TEXT,
        v_valid_from TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_valid_to TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '9999-12-31 23:59:59',
        v_last_change TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_deleted VARCHAR(1) NOT NULL DEFAULT 'N',
        v_changed_by TEXT NOT NULL DEFAULT 'n/a',
        PRIMARY KEY (id,v_valid_to)
);