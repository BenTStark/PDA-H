-- -----------------------------------------------------
-- Table club.role
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'role',
        TRUE);

CREATE TABLE IF NOT EXISTS club.role (
        role_id SERIAL PRIMARY KEY,
        role_no INT NOT NULL,
        role VARCHAR(256) NOT NULL
);
