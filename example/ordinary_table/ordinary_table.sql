SELECT
    root.f_drop_config ('example',
        'ordinary_table',
        NULL);

CREATE TABLE IF NOT EXISTS example.ordinary_table (
        id SERIAL NOT NULL,
        info TEXT NOT NULL
);