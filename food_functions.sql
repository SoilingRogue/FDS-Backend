------------------------- Food Functionalities -----------------------------
/*
* Functions:
* getFoodData(): Get food data information
*/

-- Get Food Data
DROP FUNCTION IF EXISTS getFoodData;
CREATE FUNCTION getFoodData()
 RETURNS setof json
AS $$
BEGIN
 
 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT F1.foodName, R1.rName, R1.rid, F1.price, F1.availability, F1.dailyLimit - F1.currentOrders
    FROM FoodItems F1 join Restaurants R1 USING (rid)
    ) t;

END;
$$ LANGUAGE 'plpgsql';