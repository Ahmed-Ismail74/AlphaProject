DO $$DECLARE
    tabname RECORD;
BEGIN
    FOR tabname IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || tabname.tablename || ' CASCADE;';
    END LOOP;
END$$;
-- Delete all tables