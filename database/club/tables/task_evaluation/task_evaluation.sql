-- -----------------------------------------------------
-- Table club.comment
--
-- Kommentar Relationships;
-- Ersteller (unique)
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'task_evaluation',
        NULL);

CREATE TABLE IF NOT EXISTS club.task_evaluation (
        task_evaluation_id SERIAL PRIMARY KEY,
        task_id INT NOT NULL,
        person_id INT NOT NULL,
        time_value INT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        modified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN task_evaluation.time_value IS 'Time in Minutes';
