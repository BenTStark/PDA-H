-- -----------------------------------------------------
-- Table club.court
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'court',
        NULL);

CREATE TABLE IF NOT EXISTS club.court (
        court_id INT NOT NULL,
        court_no INT NOT NULL,
        court_surface VARCHAR(256) NOT NULL,
        court_type VARCHAR(256) NOT NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        changed_by TEXT NOT NULL,
        PRIMARY KEY (court_id,
            valid_to)
);
