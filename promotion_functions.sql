------------------------- Promotion Functionalities -----------------------------
/*
* Functions:
* getFoodData(): Get promotions the order can receive
* getRestaurants(): Use actual promotion
*/

DROP FUNCTION IF EXISTS getValidPromotions;
CREATE FUNCTION getValidPromotions(inputUid INTEGER)
RETURNS setof INTEGER
AS $$
BEGIN
    RETURN QUERY SELECT ;
END;
$$ LANGUAGE 'plpgsql';




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