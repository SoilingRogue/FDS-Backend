-- write triggers here

-- still work in progress, since scheduling has not been settled yet
-- first trigger - enforcing more than 5 workers per time schedule
CREATE OR REPLACE FUNCTION  checkmorethan5perhour() RETURNS TRIGGER AS $$
DECLARE

BEGIN
-- look through all 
    IF FOUND THEN
        RAISE exception;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS checkmorethan5perhour_trigger ON yyyy;
CREATE TRIGGER checkmorethan5perhour_trigger
    AFTER DELETE OR UPDATE shifttiming ON schedule_table
    deferrable initially deferred
    FOR EACH ROW EXECUTE FUNCTION checkmorethan5perhour();


-- second trigger - making sure there are enough free riders to deliver before a customer can place an order





