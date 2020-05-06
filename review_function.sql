------------------------- Review Functionalities -----------------------------
/*
* Functions:
* getPastOrders(uid): Get past orders information
* addReviewAndRating(oid, rating, review): Record a review and rating

* Helper Function:
* getOrderRestName(oid): Get the restaurant name serving the order 
*/

-- Get past orders
DROP FUNCTION IF EXISTS getPastOrders;
CREATE FUNCTION getPastOrders(inputUid INTEGER)
 RETURNS SETOF JSON
AS $$
BEGIN
    RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t2))) FROM (
            WITH TEMP1 AS (SELECT D.oid, D.tOrderPlaced, T.uid, D.isCompleted FROM Delivers D JOIN Places T USING (oid)),
            TEMP2 AS (SELECT t.oid, t.tOrderPlaced, t.uid, t.isCompleted FROM TEMP1 t WHERE t.uid = inputUid AND t.isCompleted = TRUE)
            SELECT t.oid as oid, t.tOrderPlaced as tOrderPlaced, (SELECT getOrderRestName(oid)) as rname FROM TEMP2 t) t2;
            
END;
$$ LANGUAGE 'plpgsql';

-- Get the restaurant serving the order
DROP FUNCTION IF EXISTS getOrderRestName;
CREATE FUNCTION getOrderRestName(inputOid INTEGER)
 RETURNS VARCHAR(50)
AS $$
BEGIN
 
 RETURN (
     WITH temp AS (SELECT t.rname, t.rid, t.foodName FROM (Restaurants NATURAL JOIN FoodItems) t)
     SELECT t.rname
     FROM (temp NATURAL JOIN ConsistsOf) t
     WHERE t.oid = inputOid
     LIMIT 1);
END;
$$ LANGUAGE 'plpgsql';