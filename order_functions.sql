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

-- * Not Completed cause need schedule stuff to be done first
-- Record new order and assign rider to newly created order
DROP TYPE IF EXISTS FoodItemQty;
CREATE TYPE FoodItemQty AS (rid INTEGER, foodName VARCHAR(50), qty INTEGER);
DROP FUNCTION IF EXISTS addOrder;
CREATE FUNCTION addOrder(uId INTEGER, foodItemsArr FoodItemQty[], newFoodCost FLOAT, 
	newDeliveryCost FLOAT, newTotalCost FLOAT, newPointsUsed INTEGER, newDeliverLocation TEXT)
 RETURNS VOID
AS $$
DECLARE
 newFoodItem FoodItemQty[];
 newOid INTEGER;
BEGIN

 -- Insert into Order
 INSERT INTO Orders(foodCost, deliveryCost, totalCost, pointsUsed, ordered_at, deliverLocation)
 VALUES(newFoodCost, newDeliveryCost, newTotalCost, newPointsUsed, DEFAULT, newDeliverLocation)
 RETURNING oid
 INTO newOid;
 	
 -- Update stock and add to consists of
 FOREACH newFoodItem IN ARRAY foodItemsArr
 LOOP
 	UPDATE FoodItems SET currentStock = (currentStock - newFoodItem.qty) 
 	WHERE (newFoodItem.rid, newFoodItem.foodName) = (rid, foodName);
    
    INSERT INTO ConsistsOf VALUES (newOid, newFoodItem.foodName, newFoodCost.rid, newFoodItem.qty)
 END LOOP;

-- Update customer rewards points
UPDATE Customers SET rewardPoints = rewardPoints + 1 WHERE uId = 1;

-- Assign delivery rider
INSERT INTO Delivers (uid, oid, tOrderPlaced) VALUES (2, newOid, DEFAULT);

    COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;
$$ LANGUAGE 'plpgsql';