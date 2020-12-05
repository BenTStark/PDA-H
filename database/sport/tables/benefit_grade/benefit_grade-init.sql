-- z.B. Spielergehalt oder Aufwandsentschädigung
INSERT INTO sport.benefit_grade (benefit_grade_name, benefit_grade_sort)
    VALUES ('direkte Zahlung', '001');

-- z.B. Trainerkosten
INSERT INTO sport.benefit_grade (benefit_grade_name, benefit_grade_sort)
    VALUES ('indirekte Zahlung', '002');

-- z.B. Gästestunde, Hallenstunde
INSERT INTO sport.benefit_grade (benefit_grade_name, benefit_grade_sort)
    VALUES ('Zahlungserlass', '003');

-- z.B. Kosten Liga
INSERT INTO sport.benefit_grade (benefit_grade_name, benefit_grade_sort)
    VALUES ('Vereinszweck', '004');
