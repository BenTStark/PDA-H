-- -----------------------------------------------------
-- Table club.image
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'image',
        TRUE);

CREATE TABLE IF NOT EXISTS club.image (
        image_id BIGSERIAL PRIMARY KEY,
        name VARCHAR(256) NOT NULL,
        url VARCHAR(256) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL
);
