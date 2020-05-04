------------------------- Adding Food Functionalities -----------------------------
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
    SELECT S1.foodName, S1.rName, F1.price, F1.availability, F1.currentStock
    FROM Sells S1 JOIN FoodItems F1 USING (foodName)
    ) t;

END;
$$ LANGUAGE 'plpgsql';