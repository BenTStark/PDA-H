SELECT
    root.f_drop_config ('root',
        'rep_table',
        NULL);

CREATE TABLE IF NOT EXISTS root.rep_table (
        court_id INT NOT NULL,
        court_status_list_id INT NOT NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        changed_by TEXT NOT NULL,
        PRIMARY KEY (court_id,
            valid_to)
);

SELECT root.f_config('root','rep_table',true,true);
