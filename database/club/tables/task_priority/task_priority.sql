-- -----------------------------------------------------
-- Table club.task_priority
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'task_priority',
        TRUE);

CREATE TABLE IF NOT EXISTS club.task_priority (
        task_priority_id SERIAL PRIMARY KEY,
        task_priority_no INT NOT NULL,
        task_priority VARCHAR(256) NOT NULL
);
