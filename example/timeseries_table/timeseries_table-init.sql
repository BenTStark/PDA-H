INSERT INTO example.vt_timeseries_table (id,info,valid_from,valid_to,modified_at,changed_by) VALUES (1,'some info','2020-01-01 00:00:00','2020-12-31 23:59:59',now(),USER::text);
INSERT INTO example.vt_timeseries_table (id,info,valid_from,valid_to,modified_at,changed_by) VALUES (2,'some other info','2020-01-01 00:00:00','2020-07-31 23:59:59',now(),USER::text);
INSERT INTO example.vt_timeseries_table (id,info,valid_from,valid_to,modified_at,changed_by) VALUES (1,'some info, but not important because not part of Primary Key','2021-05-01 00:00:00','2021-12-31 23:59:59',now(),USER::text);
INSERT INTO example.vt_timeseries_table (id,info,valid_from,valid_to,modified_at,changed_by) VALUES (1,'some info again','2020-10-01 00:00:00','2020-07-15 23:59:59',now(),USER::text);
