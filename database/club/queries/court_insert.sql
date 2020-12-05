-- Should be used for court updates
--SET {0}:=1;
--SET {1}:=1;
--SET {2}:='Hardcourt';
--SET {3}:='Freiplatz';
--SET {4}:=TIMESTAMPTZ '2020-07-15 00:00:00';
--SET {5}:=TIMESTAMPTZ '9999-12-31 23:59:59';
--SET {6}:=CURRENT_TIMESTAMP;
--SET {7}:='stk';
INSERT INTO club.court (court_id, court_no, court_surface, court_type, valid_from, valid_to, modified_at, changed_by)
SELECT
    COALESCE({0}, nextval('club.seq_court_court_id')), {1}, {2}, {3}, COALESCE({4}, CURRENT_TIMESTAMP), COALESCE({5}, TIMESTAMPTZ '9999-12-31 23:59:59'), COALESCE({6}, CURRENT_TIMESTAMP), {7};
