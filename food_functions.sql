------------------------- Food Functionalities -----------------------------
/*
* Functions:
* getFoodData(): Get food data information
* getRestaurants(): Get restaurants
* getRestaurantFoodData(uid): Get food data from the restaurant that the staff belongs to
*/

-- Get Food Data
DROP FUNCTION IF EXISTS getFoodData;
CREATE FUNCTION getFoodData()
 RETURNS setof json
AS $$
BEGIN
 
 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT F1.foodName, R1.rName, R1.rid, F1.price, F1.availability, F1.dailyLimit - F1.currentOrders
    FROM FoodItems F1 JOIN Restaurants R1 USING (rid)
    ) t;

END;
$$ LANGUAGE 'plpgsql';

-- Get Food Data
DROP FUNCTION IF EXISTS getRestaurants;
CREATE FUNCTION getRestaurants()
 RETURNS setof json
AS $$
BEGIN
 
 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT R.rid, R.rName
    FROM Restaurants R) t;

END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS addAvailability;
CREATE FUNCTION addAvailability(name INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE FoodItems SET availability = (availability + 1) WHERE foodName = name;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record to database';
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS minusAvailability;
CREATE FUNCTION minusAvailability(name INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE FoodItems SET availability = (availability - 1) WHERE foodName = name;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record to database';
END;
$$ LANGUAGE 'plpgsql';

/*
-- Get Food Data
DROP FUNCTION IF EXISTS getRestaurantFoodData;
CREATE FUNCTION getRestaurantFoodData(staffId integer)
 RETURNS setof json
AS $$
BEGIN
 
 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT F1.foodName, R1.rName, R1.rid, F1.price, F1.availability, F1.dailyLimit - F1.currentOrders
    FROM (FoodItems F1 JOIN Restaurants R1 USING (R1.rid)) JOIN RestaurantStaff S1 USING (S1.uid)
    WHERE S1.uid = staffId
    ) t;

END;
$$ LANGUAGE 'plpgsql';
*/