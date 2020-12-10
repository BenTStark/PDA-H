SELECT
    root.f_drop_config ('root',
        'test_timeseries',
        NULL);

CREATE TABLE IF NOT EXISTS root.test_timeseries (
        id SERIAL NOT NULL,
        info TEXT NOT NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        changed_by TEXT NOT NULL,
        PRIMARY KEY (id,
            valid_to)
);

SELECT root.f_config ( 'root', 'test_timeseries' ,  false,  NULL,  NULL,  true,  false);