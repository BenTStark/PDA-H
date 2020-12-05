-- -----------------------------------------------------
-- Table root.changelog
-- -----------------------------------------------------
SELECT root.f_drop_config('root','changelog',NULL);

CREATE TABLE IF NOT EXISTS root.changelog (
	changelog_id SERIAL PRIMARY KEY,
	changegroup_id BIGINT,
	table_name TEXT,
	column_name TEXT,
	column_data_type TEXT,
	old_value TEXT,
	new_value text
);
