-- -----------------------------------------------------
-- Table club.task_status
--
-- "Erstellt": sollen nur für Administratoren sichtbar sein. Damit soll eine Planung ermöglicht werden. Außerdem kann man so schnell etwas erfassen und erst später ausarbeiten.
-- "Offen": können vom Mitglieder übernommen werden
-- "in Bearbeitung": werden derzeit bearbeitet
-- "Gelöst": Der/Die Ticketbearbeiter haben das Ticket gelöst und warten auf Abnahme
-- "Abgenommen": Ticket ist final abgeschlossen
-- "Nachbesserung nötig": Der/Die Bearbeiter müssen nochmals nachbessern um das Ticket abzuschließen.
-- -----------------------------------------------------
SELECT
    root.f_check_if_table_exists ('club',
        'task_status',
        TRUE);

CREATE TABLE IF NOT EXISTS club.task_status (
        task_status_id SERIAL PRIMARY KEY,
        task_status_no INT NOT NULL,
        task_status VARCHAR(256) NOT NULL
);
