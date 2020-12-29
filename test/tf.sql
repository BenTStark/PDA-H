DROP FUNCTION IF EXISTS test.tf ();

CREATE OR REPLACE FUNCTION test.tf ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $Body$
DECLARE
    var_id int4 DEFAULT nextval('test.testdefault_id_seq'::regclass);
    var_info text DEFAULT 'Bla'::text;
    var_nuller text;
BEGIN
    IF NEW.id IS NOT NULL THEN 
        var_id := NEW.id;
    END IF;

    raise notice '%', var_id;

    IF NEW.info IS NOT NULL THEN 
        var_info := NEW.info;
    END IF;

    raise notice '%', var_info;

    IF NEW.nuller IS NOT NULL THEN 
        var_nuller := NEW.nuller;
    END IF;

    raise notice '%', var_nuller;
    IF var_id <> 1 THEN
        UPDATE test.testdefault SET info = var_id::text WHERE id = 1;
    END IF;
    INSERT INTO test.testdefault (id,info,nuller) VALUES (var_id,var_info,var_nuller);
    RETURN NULL;
     
END;
$Body$
