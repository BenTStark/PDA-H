CREATE TRIGGER t_instead_of_vv_test_table INSTEAD OF INSERT
OR
UPDATE
OR DELETE
ON root.vv_test_table FOR EACH ROW EXECUTE PROCEDURE root.tf_instead_of_vv_test_table ();

/* 
BEGIN
    
    PERFORM
        root. tf_instead_of_vv_test_table (NEW.info,NEW.normal_col,NEW.update_col,NEW.ignore_col);
            
    RETURN NULL;
END 
*/