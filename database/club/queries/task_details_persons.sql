-- {0}:=2;
-- Personen eines Tickets
SELECT
    rt.relationship_type, -- Für einen Link zum Profil
    p.person_no,
    p.first_name,
    p.last_name
FROM
    club.task t
    LEFT JOIN club.relationship r ON t.task_id = r.source_id
    LEFT JOIN club.person p ON r.target_id = p.person_id
    LEFT JOIN club.relationship_type rt ON r.relationship_type_id = rt.relationship_type_id
WHERE
    1 = 1
    AND r.source = 'task'
    AND r.target = 'person'
    AND t.task_no = {0};
