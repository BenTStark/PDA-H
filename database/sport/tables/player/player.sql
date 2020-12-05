-- -----------------------------------------------------
-- Table sport.player
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'player',
        TRUE);

CREATE TABLE IF NOT EXISTS sport.player (
        player_id SERIAL PRIMARY KEY,
        member_no INT NOT NULL
);
