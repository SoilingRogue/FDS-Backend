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
DROP FUNCTION IF EXISTS findAvailableRider;
CREATE FUNCTION findAvailableRider()
RETURNS INTEGER
AS $$
BEGIN
    RETURN (
        SELECT uid
        FROM DeliveryRiders
        WHERE deliveryStatus = 0
        LIMIT 1
    );
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTDepartToRest;
CREATE FUNCTION setTDepartToRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartToRest = NOW() WHERE uid = riderId AND tDeliverOrder IS NULL;
    UPDATE DeliveryRiders SET deliveryStatus = 2 WHERE uid = riderId;
COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTArriveAtRest;
CREATE FUNCTION setTArriveAtRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartToRest = NOW() WHERE uid = riderId AND tDeliverOrder IS NULL;
    UPDATE DeliveryRiders SET deliveryStatus = 3 WHERE uid = riderId;
COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTDepartFromRest;
CREATE FUNCTION setTDepartFromRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartToRest = NOW() WHERE uid = riderId AND tDeliverOrder IS NULL;
    UPDATE DeliveryRiders SET deliveryStatus = 4 WHERE uid = riderId;
COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTDeliverOrder;
CREATE FUNCTION setTDeliverOrder(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartToRest = NOW() WHERE uid = riderId AND tDeliverOrder IS NULL;
    UPDATE DeliveryRiders SET deliveryStatus = 0 WHERE uid = riderId;
COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END;
$$ LANGUAGE 'plpgsql';

DROP TYPE IF EXISTS FoodItemQty CASCADE;
CREATE TYPE FoodItemQty AS (rid INTEGER, foodName VARCHAR(50), qty INTEGER);

DROP FUNCTION IF EXISTS addOrder;
CREATE PROCEDURE addOrder(inputUid INTEGER, foodItemsArr FoodItemQty[], newFoodCost FLOAT, 
	newDeliveryCost FLOAT, newTotalCost FLOAT, newPointsUsed INTEGER, newDeliverLocation TEXT)
LANGUAGE 'plpgsql'
AS $$
DECLARE
 newFoodItem FoodItemQty;
 newOid INTEGER;
 riderId INTEGER;
BEGIN

 -- Insert into Order
 INSERT INTO Orders(foodCost, deliveryCost, totalCost, pointsUsed, ordered_at, deliveryLocation)
 VALUES(newFoodCost, newDeliveryCost, newTotalCost, newPointsUsed, DEFAULT, newDeliverLocation)
 RETURNING oid
 INTO newOid;
 	
 -- Update stock and add to consists of
 FOREACH newFoodItem IN ARRAY foodItemsArr
 LOOP
 	UPDATE FoodItems SET currentStock = (currentStock - newFoodItem.qty) 
 	WHERE (newFoodItem.rid, newFoodItem.foodName) = (rid, foodName);
    
    INSERT INTO ConsistsOf (oid, foodName, rid, quantity) VALUES (newOid, newFoodItem.foodName, newFoodItem.rid, newFoodItem.qty);
 END LOOP;

-- Update customer rewards points
UPDATE Customers SET rewardPoints = rewardPoints + 1 WHERE uid = inputUid;

-- Assign delivery rider
SELECT findAvailableRider() INTO riderId;
INSERT INTO Delivers (uid, oid, tOrderPlaced) VALUES (riderId, newOid, DEFAULT);

-- Update delivery rider status
UPDATE DeliveryRiders SET deliveryStatus = 1 WHERE uid = riderId;

EXCEPTION
   WHEN others THEN
    RAISE EXCEPTION 'Failed to place order';
END;
$$;
