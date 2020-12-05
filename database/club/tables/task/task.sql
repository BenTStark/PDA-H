-- -----------------------------------------------------
-- Table club.task
--
-- Ticket Relationships:
-- Ersteller (unique)
-- Bearbeiter (multiple)
-- Kommentar (multiple)
-- Abnehmer (multiple)
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'task',
        NULL);

CREATE TABLE IF NOT EXISTS club.task (
        task_id BIGSERIAL PRIMARY KEY,
        task_no INT NOT NULL,
        title VARCHAR(256) NOT NULL,
        description TEXT,
        task_priority_id INT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        due_date TIMESTAMPTZ,
        task_status_id INT,
        resolution_date TIMESTAMPTZ
);
