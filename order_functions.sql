------------------------- Order Functionalities -----------------------------
/*
* Customer Functions:
* getCustomerRewardPoints(uid): Get customer's available reward points
* getRecentOrderLocations(uid): Get recent order locations for a particular customer
* hasOngoingOrder(uid): Check ongoing order for customer
* getRestaurantMinCost(rid): Get minimum order cost for a restaurant
* findAvailableRider(): Get the first available delivery rider
* placeOrder(inputUid, foodItemsArr, newFoodCost, newDeliveryCost, newTotalCost, newPointsUsed, newDeliveryLocation): Transaction to place order

* Rider Functions:
* setTDepartToRest(uid): Update database when rider departs for restaurant
* setTArriveAtRest(uid): Update database when rider arrives restaurant
* setTDepartFromRest(uid): Update database when rider departs from restaurant
* setTDeliverOrder(uid): Update database when rider completes the delivery
*/

-- Customer Functions

-- Get customer's available reward points
DROP FUNCTION IF EXISTS getCustomerRewardPoints;
CREATE FUNCTION getCustomerRewardPoints(inputUid INTEGER)
 RETURNS INTEGER
AS $$
BEGIN
 
 RETURN (SELECT rewardPoints FROM Customers WHERE uid = inputUid);

END;
$$ LANGUAGE 'plpgsql';

-- Get customer's available reward points
DROP FUNCTION IF EXISTS getRecentOrderLocations;
CREATE FUNCTION getRecentOrderLocations(inputUid INTEGER)
 RETURNS setof TEXT
AS $$
BEGIN
 
 RETURN QUERY (
    WITH completedOrders AS (
        SELECT oid, deliveryLocation, tOrderPlaced
        FROM Orders natural join Delivers WHERE isCompleted = TRUE)
    SELECT deliveryLocation
    FROM completedOrders NATURAL JOIN Places
    WHERE uid = inputUid
    ORDER BY tOrderPlaced DESC
    LIMIT 5);

END;
$$ LANGUAGE 'plpgsql';

-- Get customer's ongoing order, returns restaurant name
DROP FUNCTION IF EXISTS hasOngoingOrder;
CREATE FUNCTION hasOngoingOrder(inputUid INTEGER)
 RETURNS BOOLEAN
AS $$
BEGIN
 
 RETURN (
    WITH ongoingOrder AS (
        SELECT oid
        FROM Orders natural join Delivers WHERE isCompleted = FALSE)
    SELECT exists (
        select 1
        FROM ongoingOrder NATURAL JOIN Places
        WHERE uid = inputUid));

END;
$$ LANGUAGE 'plpgsql';

-- Get minimum order cost for a restaurant
DROP FUNCTION IF EXISTS getRestaurantMinCost;
CREATE FUNCTION getRestaurantMinCost(inputRid INTEGER)
 RETURNS FLOAT
AS $$
BEGIN
 
 RETURN (SELECT minOrderCost FROM Restaurants R1 where inputRid = R1.rid);

END;
$$ LANGUAGE 'plpgsql';

-- Get the first available delivery rider
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

-- Transaction to place order
DROP TYPE IF EXISTS FoodItemQty CASCADE;
CREATE TYPE FoodItemQty AS (rid INTEGER, foodName VARCHAR(50), qty INTEGER);

DROP FUNCTION IF EXISTS placeOrder;
CREATE PROCEDURE placeOrder(inputUid INTEGER, foodItemsArr FoodItemQty[], newFoodCost FLOAT, 
	newDeliveryCost FLOAT, newTotalCost FLOAT, newPointsUsed INTEGER, newDeliveryLocation TEXT)
LANGUAGE 'plpgsql'
AS $$
DECLARE
 newFoodItem FoodItemQty;
 newOid INTEGER;
 riderId INTEGER;
BEGIN

 -- Check if food cost >= minOrderCost of restaurant 

 -- Insert into Order
 INSERT INTO Orders (foodCost, deliveryCost, totalCost, pointsUsed, ordered_at, deliveryLocation)
 VALUES (newFoodCost, newDeliveryCost, newTotalCost, newPointsUsed, DEFAULT, newDeliveryLocation)
 RETURNING oid
 INTO newOid;
 	
 -- Update places table
 INSERT INTO Places (uid, oid) VALUES (inputUid, newOid);

 -- Update current order count and add to consists of
 FOREACH newFoodItem IN ARRAY foodItemsArr
 LOOP
 	UPDATE FoodItems SET currentOrders = (currentOrders - 1) 
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
    RAISE EXCEPTION 'Failed to place order. Try again later...';
END;
$$;

-- Rider Functions

DROP FUNCTION IF EXISTS setTDepartToRest;
CREATE FUNCTION setTDepartToRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartToRest = NOW() WHERE uid = riderId AND isCompleted = FALSE;
    UPDATE DeliveryRiders SET deliveryStatus = 2 WHERE uid = riderId;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record time to database';
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTArriveAtRest;
CREATE FUNCTION setTArriveAtRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tArriveAtRest = NOW() WHERE uid = riderId AND isCompleted = FALSE;
    UPDATE DeliveryRiders SET deliveryStatus = 3 WHERE uid = riderId;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record time to database';
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTDepartFromRest;
CREATE FUNCTION setTDepartFromRest(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDepartFromRest = NOW() WHERE uid = riderId AND isCompleted = FALSE;
    UPDATE DeliveryRiders SET deliveryStatus = 4 WHERE uid = riderId;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record time to database';
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS setTDeliverOrder;
CREATE FUNCTION setTDeliverOrder(riderId INTEGER)
RETURNS void
AS $$
BEGIN
    UPDATE Delivers SET tDeliverOrder = NOW(), isCompleted = TRUE WHERE uid = riderId AND isCompleted = FALSE;
    UPDATE DeliveryRiders SET deliveryStatus = 0 WHERE uid = riderId;
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to record time to database';
END;
$$ LANGUAGE 'plpgsql';
