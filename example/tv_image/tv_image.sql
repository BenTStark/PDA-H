SELECT
    root.f_drop_config ('example',
        'tv_image',
        NULL);

CREATE TABLE IF NOT EXISTS example.tv_image (
        id SERIAL NOT NULL,
        image_url TEXT,
        image_name TEXT,
        v_valid_from TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_valid_to TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '9999-12-31 23:59:59',
        v_last_change TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ '1970-01-01 00:00:00',
        v_deleted VARCHAR(1) NOT NULL DEFAULT 'N',
        v_changed_by TEXT NOT NULL DEFAULT 'n/a',
        PRIMARY KEY (id,v_valid_to)
);