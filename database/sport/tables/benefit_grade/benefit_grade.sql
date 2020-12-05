-- -----------------------------------------------------
-- Table sport.benefit_grade
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('sport',
        'benefit_grade',
        TRUE);

CREATE TABLE IF NOT EXISTS sport.benefit_grade (
        benefit_grade_id SERIAL PRIMARY KEY,
        benefit_grade_name VARCHAR(256) NOT NULL,
        benefit_grade_sort VARCHAR(3) NOT NULL
);
