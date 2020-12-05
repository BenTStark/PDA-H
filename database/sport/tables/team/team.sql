-- -----------------------------------------------------
-- Table sport.team
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('sport',
        'team',
        NULL);

CREATE TABLE IF NOT EXISTS sport.team (
        team_id INT NOT NULL,
        team_name VARCHAR(256) NOT NULL,
        season VARCHAR(256) NOT NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        modified_at TIMESTAMPTZ NOT NULL,
        changed_by TEXT NOT NULL,
        PRIMARY KEY (team_id,
            valid_to)
);

COMMENT ON COLUMN team.season IS 'Winter- or Sommerrunde';
