------------------------- Order Functionalities -----------------------------
/*
* Functions:
* getRestaurantMinCost(rid): Get minimum order cost for a restaurant
*/

DROP FUNCTION IF EXISTS getRestaurantMinCost;
CREATE FUNCTION getRestaurantMinCost(inputRid INTEGER)
 RETURNS setof FLOAT
AS $$
BEGIN
 
 RETURN QUERY SELECT minOrderCost FROM Restaurants R1 where inputRid = R1.rid;

END;
$$ LANGUAGE 'plpgsql';