-- -----------------------------------------------------
-- Table root.changegroup
-- -----------------------------------------------------
SELECT root.f_drop_config('root','changegroup',NULL);

CREATE TABLE IF NOT EXISTS changegroup (
	changegroup_id BIGSERIAL PRIMARY KEY,
	userid TEXT,
	created_at TIMESTAMPTZ,
	operation TEXT,
	context TEXT
);
