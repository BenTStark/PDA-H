-- timezone einstellen, am besten INITAL CONFIG script
--TRUNCATE TABLE club.court_status;
INSERT INTO club.court_status (court_id, court_status_list_id, valid_from, valid_to, modified_at, changed_by)
SELECT
    c.court_id, csl.court_status_list_id, TIMESTAMPTZ '2019-01-01 00:00:00' AS valid_from, TIMESTAMPTZ '9999-12-31 23:59:59' AS valid_to, CURRENT_TIMESTAMP AS modified_at, 'stk' AS changed_by
FROM
    club.court c
    LEFT JOIN club.court_status_list csl ON 1 = 1
WHERE
    1 = 1
    AND csl.court_status_name = 'Bespielbar'
