-- -----------------------------------------------------
-- Table club.person
-- -----------------------------------------------------
SELECT
    root.f_drop_config ('club',
        'person',
        NULL);

CREATE TABLE IF NOT EXISTS club.person (
        person_id SERIAL PRIMARY KEY,
        person_no TEXT NOT NULL,
        is_member BOOLEAN NOT NULL,
        member_no INT,
        first_name VARCHAR(256) NOT NULL,
        last_name VARCHAR(256) NOT NULL
);

COMMENT ON COLUMN person.person_no IS 'Refers to Auth0 User ID.';

COMMENT ON COLUMN person.is_member IS 'Not every person must be a user, e.g. indoor guest player.';

COMMENT ON COLUMN person.member_no IS 'Member Number according to Club CRM.';
