-- -----------------------------------------------------
-- Table sport.benefit_type
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('sport',
        'benefit_type',
        TRUE);

CREATE TABLE IF NOT EXISTS sport.benefit_type (
        benefit_type_id SERIAL PRIMARY KEY,
        benefit_type_name VARCHAR(256) NOT NULL
);
