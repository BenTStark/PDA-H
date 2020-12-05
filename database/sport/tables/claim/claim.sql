-- -----------------------------------------------------
-- Table sport.claim
-- Claimable Benefits, e.g. tournaments, are listed here when they are really used by the player or team.
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('sport',
        'claim',
        NULL);

CREATE TABLE IF NOT EXISTS sport.claim (
        claim_id SERIAL PRIMARY KEY,
        benefit_id INT NOT NULL,
        description VARCHAR(256) NULL,
        created_at TIMESTAMPTZ NOT NULL,
        value DECIMAL (8,
            2)
);

COMMENT ON COLUMN claim.description IS 'optional description of the claim';

COMMENT ON COLUMN claim.value IS 'The value in EUR.';
