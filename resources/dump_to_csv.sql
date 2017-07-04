-- https://stackoverflow.com/questions/17463299/export-database-into-csv-file
-- psql function to dump each table in db into its own .csv
-- usage: SELECT db_to_csv('/tmp');

CREATE OR REPLACE FUNCTION db_to_csv(path TEXT) RETURNS void AS $$
declare
   tables RECORD;
   statement TEXT;
begin
FOR tables IN
   SELECT (table_schema || '.' || table_name) AS schema_table
   FROM information_schema.tables t INNER JOIN information_schema.schemata s
   ON s.schema_name = t.table_schema
   WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema')
   AND t.table_type NOT IN ('VIEW')
   ORDER BY schema_table
LOOP
   statement := 'COPY ' || tables.schema_table || ' TO ''' || path || '/' || tables.schema_table || '.csv' ||''' DELIMITER '';'' CSV HEADER';
   EXECUTE statement;
END LOOP;
return;
end;
$$ LANGUAGE plpgsql;
