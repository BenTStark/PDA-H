-- {0}:=2;
-- Kommentare eines Tickets
SELECT
    rt.relationship_type,
    c.title,
    c.comment,
    c.created_at,
    c.modified_at, -- Für einen Link zum Profil
    p.person_no,
    p.first_name,
    p.last_name
FROM
    club.task t
    LEFT JOIN club.relationship r ON t.task_id = r.source_id
    LEFT JOIN club.comment c ON r.target_id = c.comment_id
    LEFT JOIN club.relationship r_comment ON c.comment_id = r_comment.source_id
    LEFT JOIN club.person p ON r_comment.target_id = p.person_id
    LEFT JOIN club.relationship_type rt ON r.relationship_type_id = rt.relationship_type_id
WHERE
    1 = 1
    AND r.source = 'task'
    AND r.target = 'comment'
    AND r_comment.source = 'comment'
    AND r_comment.target = 'person'
    AND t.task_no = {0};
