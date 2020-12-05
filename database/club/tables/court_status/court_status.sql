-- -----------------------------------------------------
-- Table club.court_status
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'court_status',
        NULL);

CREATE TABLE IF NOT EXISTS club.court_status (
        court_id INT NOT NULL,
        court_status_list_id INT NOT NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        changed_by TEXT NOT NULL,
        PRIMARY KEY (court_id,
            valid_to)
);
