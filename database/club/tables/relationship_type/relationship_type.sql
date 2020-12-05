-- -----------------------------------------------------
-- Table club.relationship_type
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'relationship_type',
        TRUE);

CREATE TABLE IF NOT EXISTS club.relationship_type (
        relationship_type_id SERIAL PRIMARY KEY,
        relationship_type_no INT NOT NULL,
        relationship_type VARCHAR(256) NOT NULL
);
