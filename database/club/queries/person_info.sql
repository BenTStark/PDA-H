--{0}:= 9;
SELECT
    p.person_no,
    p.first_name,
    p.last_name,
    p.member_no,
    ro.role
FROM
    club.person p
    LEFT JOIN club.relationship r ON p.person_id = r.source_id
    LEFT JOIN club.relationship_type rt ON r.relationship_type_id = rt.relationship_type_id
    LEFT JOIN club.role ro ON r.target_id = ro.role_id
WHERE
    1 = 1
    AND rt.relationship_type_no = 6 /* Rolle */
    AND p.person_no = {0}
