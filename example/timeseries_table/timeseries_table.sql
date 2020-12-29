SELECT
    root.f_drop_config ('example',
        'timeseries_table',
        NULL);

CREATE TABLE IF NOT EXISTS example.timeseries_table (
        id SERIAL NOT NULL,
        info TEXT NOT NULL DEFAULT 'info',
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        changed_by TEXT NOT NULL DEFAULT 'n/a',
        PRIMARY KEY (id,
            valid_to)
);

SELECT root.f_config ( 'example', 'timeseries_table' ,  false,  NULL,  NULL,  true,  true);