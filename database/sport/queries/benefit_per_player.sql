-- Im Zeitraum (hier '2019-01-01 00:00:00' bis '2012-01-01 00:00:00') soll pro Spieler ermittelt werden welche Benefits ein Spieler genießt
-- Parameter müssen sein:
-- 1. Spieler (member_no)
-- 2. Zeitraum (von bis: z.B. Geschäftsjahr und Sommer + Wintersaison als Voreinstellungen: View?)
--set {0}:=2;
--set {1}:=TIMESTAMPTZ '2019-01-01 00:00:00';
--set {2}:=TIMESTAMPTZ '2020-01-01 00:00:00';
SELECT
    basis.member_no,
    basis.description,
    basis.sum_part_time,
    CASE WHEN basis.is_claimable THEN
        basis.sum_claim
    ELSE
        basis.sum_part_time
    END AS sum_claim
FROM (
    SELECT
        p.member_no,
        b.description, -- Benefits die vom Betrachtungszeitraum abweichen sollen nur anteilig eingerechnet werden.
        sport.f_date_period_part ({1},
            {2},
            b.valid_from,
            b.valid_to) * CASE WHEN b.value IS NULL THEN
            b.cap_sum_value
        ELSE
            b.count * b.value
END / cnt_team_members AS sum_part_time,
c.value / cnt_team_members AS sum_claim,
b.is_claimable
FROM
    sport.benefit b -- Die Summe der tatsächlich eingeforderten Benefitsumme pro benefit_id
    LEFT JOIN (
        SELECT
            c.benefit_id,
            SUM(c.value) AS value
        FROM
            sport.claim c
        WHERE
            1 = 1
            AND c.created_at >= {1}
            AND c.created_at < {2}
        GROUP BY
            c.benefit_id) c ON c.benefit_id = b.benefit_id
    LEFT JOIN sport.team t ON b.entity_id = t.team_id
    LEFT JOIN sport.team_members tm ON t.team_id = tm.team_id
    LEFT JOIN (
        SELECT
            tm.team_id,
            COUNT(*) AS cnt_team_members
        FROM
            sport.team_members tm
        WHERE
            1 = 1
            AND tm.is_main_team = TRUE
        GROUP BY
            team_id) tm_count ON tm.team_id = tm_count.team_id
    LEFT JOIN sport.player p ON tm.player_id = p.player_id
    LEFT JOIN club.person pers ON p.member_no = p.member_no
WHERE
    1 = 1
    AND entity = 'team'
    AND p.member_no = {0}
    AND ((b.valid_from <= {1}
            AND b.valid_to > {1})
        OR (b.valid_from < {2}
            AND b.valid_to >= {2})
        OR (b.valid_from >= {1}
            AND b.valid_from < {2}))
UNION
-- Benefits pro Einzelspieler
SELECT
    p.member_no,
    b.description, -- Benefits die vom Betrachtungszeitraum abweichen sollen nur anteilig eingerechnet werden.
    sport.f_date_period_part ({1},
        {2},
        b.valid_from,
        b.valid_to) * CASE WHEN b.value IS NULL THEN
        b.cap_sum_value
    ELSE
        b.count * b.value
    END AS sum_part_time,
    c.value AS sum_claim,
    b.is_claimable
FROM
    sport.benefit b
    LEFT JOIN sport.player p ON b.entity_id = p.player_id -- Die Summe der tatsächlich eingeforderten Benefitsumme pro benefit_id
    LEFT JOIN (
        SELECT
            c.benefit_id,
            SUM(c.value) AS value
        FROM
            sport.claim c
        WHERE
            1 = 1
            AND c.created_at >= {1}
            AND c.created_at < {2}
        GROUP BY
            c.benefit_id) c ON c.benefit_id = b.benefit_id
    LEFT JOIN club.person pers ON p.member_no = p.member_no
WHERE
    1 = 1
    AND entity = 'player'
    AND p.member_no = {0}
    AND ((b.valid_from <= {1}
            AND b.valid_to > {1})
        OR (b.valid_from < {2}
            AND b.valid_to >= {2})
        OR (b.valid_from >= {1}
            AND b.valid_from < {2}))) basis
