--{0}:= TIMESTAMPTZ '2019-07-15 00:00:00';
SELECT
    c.court_id,
    c.court_no,
    csl.court_status_name,
    c.court_surface,
    c.court_type
FROM
    club.court c
    LEFT JOIN club.court_status cs ON c.court_id = cs.court_id
    AND cs.valid_to > {0}
    AND cs.valid_from <= {0}
    LEFT JOIN club.court_status_list csl ON cs.court_status_list_id = csl.court_status_list_id
WHERE
    1 = 1
    AND c.valid_to > {0}
    AND c.valid_from <= {0}
