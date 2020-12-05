-- -----------------------------------------------------
-- View club.v_court_status_frontend
-- -----------------------------------------------------
SELECT root.f_check_if_view_exists('club','v_court_status_frontend',TRUE);

CREATE OR REPLACE VIEW club.v_court_status_frontend AS
SELECT
    c.court_no,
    csl.court_status_name,
    c.court_surface,
    c.court_type
FROM
    club.court_status cs
        LEFT JOIN
    club.court c ON cs.court_id = c.court_id
        LEFT JOIN
    club.court_status_list csl ON cs.court_status_list_id = csl.court_status_list_id
WHERE 1 = 1
AND cs.valid_from <= NOW()
AND cs.valid_to > NOW()
ORDER BY c.court_no ASC
