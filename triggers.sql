-- write triggers here

-- RIDERS TRIGGERS HERE
-- enforcing more than 5 workers per time schedule
DROP FUNCTION IF EXISTS fiveRidersHourlyIntervalConstraint;
CREATE OR REPLACE FUNCTION  fiveRidersHourlyIntervalConstraint() RETURNS TRIGGER AS $$
DECLARE
    i int;
    num int;
BEGIN
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

-- ensuring PT riders have >= 10 and <= 48 hours worked per week
DROP FUNCTION IF EXISTS PTRidersWorkingConstraint;
CREATE OR REPLACE FUNCTION  PTRidersWorkingConstraint() RETURNS TRIGGER AS $$
DECLARE
    id INTEGER;
    time INTEGER;
BEGIN
    id = NEW.uid;
    SELECT SUM(*) INTO time
    FROM 
    (SELECT endTime - startTime as shiftTime FROM PTShift
    WHERE uid = id) AS temp;
    IF time < 10 or time > 48 THEN
        RAISE exception 'Invalid working hours for rider id: %', id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS PTRidersWorkingConstraint_trigger ON PTShift CASCADE;
CREATE CONSTRAINT TRIGGER PTRidersWorkingConstraint_trigger
    AFTER UPDATE OF day, startTime, endTime OR INSERT OR DELETE ON PTShift
    deferrable initially deferred
    FOR EACH ROW EXECUTE FUNCTION PTRidersWorkingConstraint();

-- ensure ftriders 5 conseq work days + only 1 shift per day
DROP FUNCTION IF EXISTS fiveConseqWorkDaysConstraint;
CREATE OR REPLACE FUNCTION fiveConseqWorkDaysConstraint() RETURNS TRIGGER AS $$
DECLARE
    id INTEGER;
BEGIN
    id = NEW.uid;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS fiveConseqWorkDaysConstraint_trigger ON FullTimeScheduling CASCADE;
CREATE CONSTRAINT TRIGGER fiveConseqWorkDaysConstraint_trigger
    AFTER UPDATE OR INSERT OR DELETE ON FullTimeScheduling
    deferrable initially deferred
    FOR EACH ROW EXECUTE FUNCTION fiveConseqWorkDaysConstraint();





