DROP FUNCTION IF EXISTS root.test_function ();

CREATE OR REPLACE FUNCTION root.test_function ()
    RETURNS TEXT
    LANGUAGE plpgsql
AS $Body$
DECLARE
    sql TEXT;
    sql_check TEXT;
    object_array VARCHAR(256) [ ];
    obj VARCHAR(256);
    has_update TEXT DEFAULT '';
    double_dollar VARCHAR(10);
    table_name VARCHAR(256);
    view_name VARCHAR(256);
    arr varchar(256)[][3];
    a varchar(256)[3];
BEGIN
    double_dollar:= FORMAT('%s', CONCAT(CHR(36), CHR(36)));
    --table_name:= FORMAT('%s.%s', var_schema_name, var_table_name);
    --view_name:= FORMAT('%s.v_%s', var_schema_name, var_table_name);
    
    
    SELECT ARRAY(
    SELECT
        ARRAY[
              c.column_name
            , c.data_type
            , CASE WHEN pk.attname IS NULL THEN 'N' ELSE 'Y' END]
	FROM information_schema.columns c
	LEFT JOIN 
        (SELECT
	        a.attname
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid
            AND a.attnum = ANY (i.indkey)
        WHERE 1 = 1
        AND i.indrelid = 'tv_test_table'::regclass
		AND i.indisprimary) pk 
    ON c.column_name = pk.attname
	WHERE 1 = 1
	AND c.table_schema = 'root'
	AND c.table_name = 'tv_test_table'
    ) into arr ;

    FOREACH a SLICE 1 in ARRAY arr
    LOOP
        raise notice '%s, %s, %s', a[1],a[2],a[3];
    END LOOP;

END;
$Body$