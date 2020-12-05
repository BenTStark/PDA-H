WITH relationship_type AS (
SELECT
    relationship_type_id
FROM
    club.relationship_type
WHERE
    1=1
    AND relationship_type_no = 2 /* Ersteller */
)
,task AS (
INSERT INTO club.task (task_no, title, description, task_priority_id, created_at, modified_at, due_date, task_status_id, resolution_date)
SELECT
    nextval('club.task_task_no_seq'), {0}, {1}, {2}, COALESCE({3}, CURRENT_TIMESTAMP), COALESCE({4}, CURRENT_TIMESTAMP), {5}, {6}, {7}
RETURNING
    task_id)
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
SELECT
    task.task_id, 'task', {8}, 'person', relationship_type.relationship_type_id
FROM
    task, rel_type
RETURNING
    currval('club.task_task_id_seq');
