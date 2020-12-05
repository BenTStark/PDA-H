-- -----------------------------------------------------
-- Table sport.benefit
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('sport',
        'benefit',
        NULL);

CREATE TABLE IF NOT EXISTS sport.benefit (
        benefit_id SERIAL PRIMARY KEY,
        benefit_type_id INT NOT NULL,
        entity_id INT NOT NULL,
        entity VARCHAR(128) NOT NULL,
        description VARCHAR(256) NULL,
        valid_from TIMESTAMPTZ NOT NULL,
        valid_to TIMESTAMPTZ NOT NULL,
        count DECIMAL (8,
            2) NOT NULL,
        amount_id INT NOT NULL,
        value DECIMAL (8,
            2),
        cap_sum_value DECIMAL (8,
            2),
        is_claimable BOOLEAN NOT NULL
);

COMMENT ON COLUMN benefit.benefit_type_id IS 'type of the benefit';

COMMENT ON COLUMN benefit.entity_id IS 'id of the entity';

COMMENT ON COLUMN benefit.entity IS 'entity to which the benefit belongs. This can be a player or a team';

COMMENT ON COLUMN benefit.description IS 'optional description of the benefit';

COMMENT ON COLUMN benefit.COUNT IS 'Number of benefits in the given time period';

COMMENT ON COLUMN benefit.value IS 'The value in EUR of the n-th count. That means if count is n, value describes the EUR of 1 count. value can be NULL but in this case the cap_sum_value should be filled.';

COMMENT ON COLUMN benefit.cap_sum_value IS 'Maximum Sum of EUR that must not be exceeded by the benefit. That means for example. You have 3 Tournaments but the cost of all 3 should no exceed 100 EUR.';

COMMENT ON COLUMN benefit.is_claimable IS 'Some benefits are claimable. For example tournaments can have an upper cap in EUR and the complete sum may not be claimed. This should be recorded.';
