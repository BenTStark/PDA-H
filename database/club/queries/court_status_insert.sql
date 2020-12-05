-- Should be used for court updates
--SET {0}:=1;
--SET {1}:=3; /* Gesperrt */
--SET {2}:=TIMESTAMPTZ '2020-07-15 00:00:00';
--SET {3}:=TIMESTAMPTZ '9999-12-31 23:59:59';
--SET {4}:=CURRENT_TIMESTAMP;
--SET {5}:='stk';
INSERT INTO club.court_status (court_id, court_status_list_id, valid_from, valid_to, modified_at, changed_by)
SELECT
    {0}, {1}, COALESCE({2}, CURRENT_TIMESTAMP), COALESCE({3}, TIMESTAMPTZ '9999-12-31 23:59:59'), COALESCE({4}, CURRENT_TIMESTAMP), {5};
