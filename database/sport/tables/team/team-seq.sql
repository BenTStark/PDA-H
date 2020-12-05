SELECT
    root.f_check_if_sequence_exists ('sport',
        'team_team_id_seq',
        TRUE);

CREATE SEQUENCE sport.team_team_id_seq
    START 1;
