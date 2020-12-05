-- -----------------------------------------------------
-- Table club.court_status_list
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'court_status_list',
        TRUE);

CREATE TABLE IF NOT EXISTS club.court_status_list (
        court_status_list_id SERIAL PRIMARY KEY,
        court_status_name VARCHAR(256) NOT NULL
);
