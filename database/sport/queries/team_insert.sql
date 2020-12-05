INSERT INTO sport.team (team_id, team_name, season, valid_from, valid_to, modified_at, changed_by)
SELECT
    COALESCE({0}, nextval('sport.seq_team_team_id'), {1}, {2}, COALESCE({3}, CURRENT_TIMESTAMP), COALESCE({4}, TIMESTAMPTZ '9999-12-31 23:59:59'), CURRENT_TIMESTAMP, 'stk';
