-- -----------------------------------------------------
-- Table sport.team
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('sport',
        'team_members',
        NULL);

CREATE TABLE IF NOT EXISTS sport.team_members (
        team_members_id SERIAL PRIMARY KEY,
        team_id INT NOT NULL,
        player_id INT NOT NULL,
        is_main_team BOOLEAN NOT NULL
);
