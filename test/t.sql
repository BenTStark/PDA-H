CREATE TRIGGER t INSTEAD OF INSERT
ON test.v_testdefault FOR EACH ROW EXECUTE PROCEDURE test.tf ();