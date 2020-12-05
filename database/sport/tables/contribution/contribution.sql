-- -----------------------------------------------------
-- Table sport.contribution
-- all extra payments from members to the club. Regular payments are membership fees, etc.
-- Extra payments can be a financial participation for courts, trainer, balls, etc. but also donations
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('sport',
        'contribution',
        NULL);

CREATE TABLE IF NOT EXISTS sport.contribution (
        contribution_id SERIAL PRIMARY KEY,
        benefit_id INT NOT NULL,
        description VARCHAR(256),
        created_at TIMESTAMPTZ NOT NULL,
        value DECIMAL (8,
            2)
);

COMMENT ON COLUMN contribution.description IS 'optional description of the contribution';

COMMENT ON COLUMN contribution.value IS 'The value in EUR.';
