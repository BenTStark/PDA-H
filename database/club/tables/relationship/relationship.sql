-- -----------------------------------------------------
-- Table club.relationship
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'relationship',
        TRUE);

CREATE TABLE IF NOT EXISTS club.relationship (
        relationship_id BIGSERIAL PRIMARY KEY,
        source_id INT NOT NULL,
        source VARCHAR(256) NOT NULL,
        target_id INT NOT NULL,
        target VARCHAR(256) NOT NULL,
        relationship_type_id INT NOT NULL
);

SELECT
    root.f_check_if_index_exists ('club',
        'idx_relationship_source_target',
        TRUE);

CREATE INDEX idx_relationship_source_target ON club.relationship (source_id, target_id);

SELECT
    root.f_check_if_index_exists ('club',
        'idx_relationship_target_source',
        TRUE);

CREATE INDEX idx_relationship_target_source ON club.relationship (target_id, source_id);
