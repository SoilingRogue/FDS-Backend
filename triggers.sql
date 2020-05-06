-- write triggers here

-- first trigger - enforcing more than 5 workers per time schedule
DROP FUNCTION IF EXISTS fiveRidersHourlyIntervalConstraint;
CREATE OR REPLACE FUNCTION  fiveRidersHourlyIntervalConstraint() RETURNS TRIGGER AS $$
DECLARE
    i int;
    num int;
BEGIN
-- look through all 
    FOR i in 10 .. 22 LOOP
        SELECT COUNT(*) INTO num
        FROM
        (SELECT P.uid
        FROM PTShift P
        WHERE P.day = NEW.day AND p.startTime <= i AND p.endTime >= i
        UNION
        SELECT uid
        FROM FullTimeScheduling natural join FTShift
        WHERE day = NEW.day AND ((start1 <= i AND end1 >= i) OR (start2 <= i AND end2 >= i))) AS WORKERS;
        IF num < 5 THEN
            RAISE exception 'Less than 5 riders for % time', i;
        END IF;
    END LOOP;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS FT_fiveRidersHourlyIntervalConstraint_trigger ON FullTimeScheduling CASCADE;
CREATE CONSTRAINT TRIGGER FT_fiveRidersHourlyIntervalConstraint_trigger
    AFTER UPDATE OF day, shift OR DELETE ON FullTimeScheduling
    deferrable initially deferred
    FOR EACH ROW EXECUTE FUNCTION fiveRidersHourlyIntervalConstraint();

DROP TRIGGER IF EXISTS PT_fiveRidersHourlyIntervalConstraint_trigger ON PTShift CASCADE;
CREATE CONSTRAINT TRIGGER PT_fiveRidersHourlyIntervalConstraint_trigger
    AFTER UPDATE OF day, startTime, endTime OR DELETE ON PTShift
    deferrable initially deferred
    FOR EACH ROW EXECUTE FUNCTION fiveRidersHourlyIntervalConstraint();

-- second trigger - making sure there are enough free riders to deliver before a customer can place an order





