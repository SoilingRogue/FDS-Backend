------------------------- Review Functionalities -----------------------------
/*
* Functions:
* getPastOrders(uid): Get past orders information
* addReviewAndRating(uid, oid, rating, review): Record a review and rating

* Helper Function:
* getOrderRestName(oid): Get the restaurant name serving the order
* getOrderRating(oid): Get the rating for an order
* getOrderReview(oid): Get the review for an order
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
            SELECT t.oid as oid, t.tOrderPlaced as tOrderPlaced, (SELECT getOrderRestName(oid)) as rname,
                (SELECT getOrderRating(oid)) as rating , (SELECT getOrderReview(oid)) as review FROM TEMP2 t
                ORDER BY tOrderPlaced DESC
                LIMIT 5) t2;
            
END;
$$ LANGUAGE 'plpgsql';

-- Get past orders
DROP FUNCTION IF EXISTS addReviewAndRating;
CREATE FUNCTION addReviewAndRating(inputUid INTEGER, inputOid INTEGER, inputRating INTEGER, inputReview VARCHAR(100))
 RETURNS VOID
AS $$
DECLARE
_drid INTEGER;
BEGIN
    INSERT INTO Reviews (uid, oid, reviewTxt) VALUES (inputUid, inputOid, inputReview);
    SELECT uid FROM Delivers WHERE oid = inputOid INTO _drid;
    INSERT INTO Rates (uid, drid, oid, rating) VALUES (inputUid, _drid, inputOid, inputRating);
EXCEPTION
   WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to add review and rating';
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


-- Get the rating of an order
DROP FUNCTION IF EXISTS getOrderRating;
CREATE FUNCTION getOrderRating(inputOid INTEGER)
 RETURNS INTEGER
AS $$
BEGIN
 
 RETURN (
     SELECT rating
     FROM Rates
     WHERE oid = inputOid);
END;
$$ LANGUAGE 'plpgsql';

-- Get the restaurant serving the order
DROP FUNCTION IF EXISTS getOrderReview;
CREATE FUNCTION getOrderReview(inputOid INTEGER)
 RETURNS VARCHAR(100)
AS $$
BEGIN
 
 RETURN (
     SELECT reviewTxt
     FROM Reviews
     WHERE oid = inputOid);
END;
$$ LANGUAGE 'plpgsql';