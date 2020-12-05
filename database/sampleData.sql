-- -------
-- Club --
-- -------
-- Person
TRUNCATE TABLE club.person;
INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (1, TRUE, 1, 'Max', 'Mustermann');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (2, TRUE, 2, 'Paul', 'Panzer');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (3, TRUE, 3, 'Boris', 'Banane');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (4, TRUE, 4, 'Daniel', 'Düsentrieb');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (5, TRUE, 5, 'Susi', 'Sorglos');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (6, TRUE, 6, 'Nina', 'Nutzlos');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (7, TRUE, 7, 'Sabine', 'Saubermann');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (8, TRUE, 8, 'Maria', 'Mustermann');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (9, FALSE, NULL, 'Peter', 'Platzwart');

INSERT INTO club.person (person_no, is_member, member_no, first_name, last_name)
    VALUES (10, TRUE, 10, 'Martin', 'Mannschaftslos');

-- Rollen
TRUNCATE TABLE club.relationship;
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (1, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (2, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (3, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (4, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (5, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (6, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (7, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (8, 'person', 2, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (9, 'person', 1, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (9, 'person', 4, 'role', 6);

INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (10, 'person', 2, 'role', 6);

-- Image
TRUNCATE TABLE club.image;
-- Image von Paul Panzer
INSERT INTO club.image (name, url, created_at, modified_at)
    VALUES ('Profilbild Paul Panzer', 'https://www.stk-garching.de/paul', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-04-01 00:00:00');

-- Image vo Boris Banane
INSERT INTO club.image (name, url, created_at, modified_at)
    VALUES ('Profilbild Boris Banane', 'https://www.stk-garching.de/boris', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-04-01 00:00:00');

-- Image von Daniel Düsentrieb
INSERT INTO club.image (name, url, created_at, modified_at)
    VALUES ('Profilbild Daniel Düsentrieb', 'https://www.stk-garching.de/daniel', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-04-01 00:00:00');

-- Task (ein offener Task und ein erstellter Task)
TRUNCATE TABLE club.task;
-- Task 1
INSERT INTO club.task (task_no, title, description, task_priority_id, created_at, modified_at, due_date, task_status_id, resolution_date)
    SELECT nextval('club.task_task_no_seq'), 'Sprenkler wechseln', 'Defekten Sprenkler auf Platz 13 wechseln', 2, TIMESTAMPTZ '2019-06-01 10:47:13', TIMESTAMPTZ '2019-06-01 10:47:13', NULL, 1, NULL;
-- Ersteller
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 9, 'person', 2;

-- Abnehmer
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 9, 'person', 3;

-- Bearbeiter 1
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 2, 'person', 1;

-- Bearbeiter 2
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 3, 'person', 1;

-- Obwohl nicht geschlossener Task, hier schon voraus eine Evaluierung für eine Person.
INSERT INTO club.task_evaluation (task_id, person_id, time_value, created_at, modified_at)
    SELECT currval('club.task_task_id_seq'), 9, 120, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP;

-- Task 2
INSERT INTO club.task (task_no, title, description, task_priority_id, created_at, modified_at, due_date, task_status_id, resolution_date)
    SELECT nextval('club.task_task_no_seq'), 'Hecke schneiden', 'Hecke zwischen Platz 3 und Platz 4 schneiden.', 3, TIMESTAMPTZ '2019-06-12 15:15:58', TIMESTAMPTZ '2019-06-12 15:35:47', NULL, 2, NULL;
-- Ersteller
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 9, 'person', 2;

-- Abnehmer
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', 9, 'person', 3;


-- comment
TRUNCATE TABLE club.comment;
-- Kommentar zu Task 2
INSERT INTO club.comment (title, comment, created_at, modified_at)
    VALUES ('Höhe', 'Wie hoch soll denn die Hecke noch sein?', TIMESTAMPTZ '2019-06-12 15:40:13', TIMESTAMPTZ '2019-06-12 15:40:13');

-- Ersteller des Kommentar
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.comment_comment_id_seq'), 'comment', 3, 'person', 2;

-- Kommentar
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    SELECT currval('club.task_task_id_seq'), 'task', currval('club.comment_comment_id_seq'), 'comment', 4;


-- Person 1 - Image
-- Image von Paul Panzer
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (2, 'person', 1, 'image', 5);

-- Image vo Boris Banane
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (3, 'person', 2, 'image', 5);

-- Image von Daniel Düsentrieb
INSERT INTO club.relationship (source_id, source, target_id, target, relationship_type_id)
    VALUES (4, 'person', 3, 'image', 5);

-- --------
-- Sport --
-- --------
-- Players
TRUNCATE TABLE sport.player;
INSERT INTO sport.player (member_no)
    VALUES (1);

INSERT INTO sport.player (member_no)
    VALUES (2);

INSERT INTO sport.player (member_no)
    VALUES (3);

INSERT INTO sport.player (member_no)
    VALUES (4);

INSERT INTO sport.player (member_no)
    VALUES (5);

INSERT INTO sport.player (member_no)
    VALUES (6);

INSERT INTO sport.player (member_no)
    VALUES (7);

INSERT INTO sport.player (member_no)
    VALUES (8);

INSERT INTO sport.player (member_no)
    VALUES (10);

-- Teams
TRUNCATE TABLE sport.team;
INSERT INTO sport.team (team_id, team_name, season, valid_from, valid_to, modified_at, changed_by)
SELECT
    nextval('sport.team_team_id_seq'), 'Herren', 'Sommerrunde 2019', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-09-30 23:59:59', CURRENT_TIMESTAMP, 'stk';

INSERT INTO sport.team (team_id, team_name, season, valid_from, valid_to, modified_at, changed_by)
SELECT
    nextval('sport.team_team_id_seq'), 'Herren 2', 'Sommerrunde 2019', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-09-30 23:59:59', CURRENT_TIMESTAMP, 'stk';

INSERT INTO sport.team (team_id, team_name, season, valid_from, valid_to, modified_at, changed_by)
SELECT
    nextval('sport.team_team_id_seq'), 'Damen', 'Sommerrunde 2019', TIMESTAMPTZ '2019-04-01 00:00:00', TIMESTAMPTZ '2019-09-30 23:59:59', CURRENT_TIMESTAMP, 'stk';

-- Team Members
TRUNCATE TABLE sport.team_members;
INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (1, 1, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (1, 2, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (1, 3, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (1, 4, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (3, 5, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (3, 6, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (3, 7, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (3, 8, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (2, 9, TRUE);

INSERT INTO sport.team_members (team_id, player_id, is_main_team)
    VALUES (1, 9, FALSE);

-- Benefit
TRUNCATE TABLE sport.benefit;
INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (2, 1, 'team', 'Hallentraining Herren am Samstag', TIMESTAMPTZ '2018-09-25 00:00:00', TIMESTAMPTZ '2019-04-20 23:59:59', 50, 1, 22, NULL, FALSE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (3, 2, 'team', 'Trainer im Sommer für Damen', TIMESTAMPTZ '2019-04-15 00:00:00', TIMESTAMPTZ '2019-09-30 23:59:59', 15, 1, 46, NULL, FALSE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (2, 2, 'team', 'Hallentraining Damen am Dienstag erste Stunde', TIMESTAMPTZ '2018-09-25 00:00:00', TIMESTAMPTZ '2019-04-20 23:59:59', 25, 1, 18, NULL, FALSE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (2, 2, 'team', 'Hallentraining Damen am Dienstag zweite Stunde', TIMESTAMPTZ '2018-09-25 00:00:00', TIMESTAMPTZ '2019-04-20 23:59:59', 25, 1, 20, NULL, FALSE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (1, 1, 'team', 'Trainingsbälle Herren', TIMESTAMPTZ '2019-01-01 00:00:00', TIMESTAMPTZ '2019-12-31 23:59:59', 104, 2, 6.9, NULL, FALSE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (8, 1, 'team', 'Essen Heimspiele', TIMESTAMPTZ '2019-05-01 00:00:00', TIMESTAMPTZ '2019-08-31 23:59:59', 4, 3, NULL, 240, TRUE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (5, 1, 'player', 'Turnierunterstützung Max', TIMESTAMPTZ '2019-01-01 00:00:00', TIMESTAMPTZ '2019-12-31 23:59:59', 4, 3, NULL, 200, TRUE);

INSERT INTO sport.benefit (benefit_type_id, entity_id, entity, description, valid_from, valid_to, count, amount_id, value, cap_sum_value, is_claimable)
    VALUES (7, 2, 'player', 'Spielergehalt Paul', TIMESTAMPTZ '2019-01-01 00:00:00', TIMESTAMPTZ '2019-12-31 23:59:59', 7, 3, NULL, 2100, TRUE);

-- claim
TRUNCATE TABLE sport.claim;
INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (6, 'Mannschaftsessen Heimspiel vs TC Tennis', TIMESTAMPTZ '2019-05-07', 54.2);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (6, 'Mannschaftsessen Heimspiel vs TC Tischennis', TIMESTAMPTZ '2019-05-21', 58.6);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (6, 'Mannschaftsessen Heimspiel vs TC Fussballtennis', TIMESTAMPTZ '2019-06-26', 60);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (7, 'Bezirksmeisterschaften', TIMESTAMPTZ '2019-04-30', 42);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (7, 'Bayerische Meisterschaften', TIMESTAMPTZ '2019-06-19', 50);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (8, 'Einsatz Medenspiel', TIMESTAMPTZ '2019-05-12', 200);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (8, 'Einsatz Medenspiel', TIMESTAMPTZ '2019-05-19', 200);

INSERT INTO sport.claim (benefit_id, description, created_at, value)
    VALUES (8, 'Siegprämie Medenspiel', TIMESTAMPTZ '2019-05-19', 100);
