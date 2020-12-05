-- -----------------------------------------------------
-- Table club.comment
--
-- Kommentar Relationships;
-- Ersteller (unique)
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'comment',
        NULL);

CREATE TABLE IF NOT EXISTS club.comment (
        comment_id BIGSERIAL PRIMARY KEY,
        title VARCHAR(256) NOT NULL,
        comment VARCHAR(256) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL
);
