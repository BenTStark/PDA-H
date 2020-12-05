-- -----------------------------------------------------
-- Table sport.amount
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('sport',
        'amount',
        TRUE);

CREATE TABLE IF NOT EXISTS sport.amount (
        amount_id SERIAL PRIMARY KEY,
        amount_name VARCHAR(256) NOT NULL
);
