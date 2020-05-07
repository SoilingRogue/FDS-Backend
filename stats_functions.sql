------------------------- Adding Manager Functionalities -----------------------------
/*
* Three main queries: getMonthlyStats(month), 
*
* Functions:
* getTotalOrder(): Get total number of orders information
* getTotalCost(): Get total cost of all orders information
* getTotalCustomers(): Get total number of customers information
* getTotalMonthlyOrder(month): Get total number of orders information in a specified month
* getTotalMonthlyCost(month): Get total cost of all orders information in a specified month
* getTotalMonthlyNewCustomer(month): Get total number of customers information in a specified month
* getMonthlyStats(month): Get total order, cost and number of customers in a specified month
* getCustMonthlyStats(month): Get customers total order, cost in a month
* getRiderMonthlyStats(month): 
*/

-- Get total number of orders
DROP FUNCTION IF EXISTS getTotalOrder;
CREATE FUNCTION getTotalOrder()
 RETURNS SETOF json
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT count(5) FROM ORDERS
 ) t;

END;
$$ LANGUAGE 'plpgsql';


-- Get total cost of allD orders
DROP FUNCTION IF EXISTS getTotalCost;
CREATE FUNCTION getTotalCost()
 RETURNS SETOF json
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT sum(totalCost) FROM ORDERS
 ) t;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of customers
DROP FUNCTION IF EXISTS getTotalCustomers;
CREATE FUNCTION getTotalCustomers()
 RETURNS SETOF json
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
     SELECT count(*) FROM Customers
  ) t;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of orders in a month
DROP FUNCTION IF EXISTS getTotalMonthlyOrder;
CREATE FUNCTION getTotalMonthlyOrder(month integer)
 RETURNS SETOF json
AS $$
BEGIN

  RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT count(*) FROM ORDERS O  
    WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month 
  ) t;

END;
$$ LANGUAGE 'plpgsql';


-- Get total cost of orders in a month
DROP FUNCTION IF EXISTS getTotalMonthlyCost;
CREATE FUNCTION getTotalMonthlyCost(month integer)
 RETURNS SETOF json
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT sum(totalCost) FROM ORDERS O 
    WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month;
 ) t;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of new customers in a month
DROP FUNCTION IF EXISTS getTotalMonthlyNewCustomer;
CREATE FUNCTION getTotalMonthlyNewCustomer(month integer)
 RETURNS SETOF json
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT count(*) FROM Customers C
    WHERE (SELECT EXTRACT(MONTH FROM C.created_at)) = month;
 ) t;
 
END;
$$ LANGUAGE 'plpgsql';


-- Get monthly statistics
DROP FUNCTION IF EXISTS getMonthlyStats;
CREATE FUNCTION getMonthlyStats(month integer)
 RETURNS SETOF json 
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT getTotalMonthlyOrder(month), getTotalMonthlyCost(month), getTotalMonthlyNewCustomer(month)
    ) t;

END;
$$ LANGUAGE 'plpgsql';



-- Get customer monthly statistics
DROP FUNCTION IF EXISTS getCustMonthlyStats;
CREATE FUNCTION getCustMonthlyStats(month integer)
 RETURNS SETOF json 
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT count(*), sum(O.totalCost)
    FROM Orders O NATURAL JOIN Places P
    WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month
    GROUP BY P.cid
    ) t;

END;
$$ LANGUAGE 'plpgsql';

-- Get rider's total orders and salary
DROP FUNCTION IF EXISTS getRiderTotalOrdersAndSalary;
CREATE FUNCTION getRiderTotalOrdersAndSalary(month integer)
 RETURNS TABLE(outputUid INTEGER, outputOrder BIGINT, outputSalary NUMERIC)
AS $$
BEGIN

 RETURN QUERY (
    SELECT uid, COUNT(*) as orders, COUNT(*) * 1.00 as salary
    FROM Delivers D
    WHERE isCompleted = TRUE
    AND (SELECT EXTRACT(MONTH FROM D.tDeliverOrder)) = month
    GROUP BY uid
    
    UNION
    
    SELECT DR.uid, 0, 0
    FROM DeliveryRiders DR
    WHERE DR.uid NOT IN (
        SELECT DISTINCT uid
        FROM Delivers D
        WHERE (SELECT EXTRACT(MONTH FROM D.tDeliverOrder)) = month));

END;
$$ LANGUAGE 'plpgsql';

-- Get rider's total num of ratings and average ratings
DROP FUNCTION IF EXISTS getRiderRatings;
CREATE FUNCTION getRiderRatings(month integer)
 RETURNS TABLE(outputUid INTEGER, outputNumOfRatings BIGINT, outputAvgRatings NUMERIC)
AS $$
BEGIN

 RETURN QUERY (
    SELECT t.drid, COUNT(*) as totalNumOfRatings, AVG(rating) as avgRating
    FROM (
        SELECT D.uid as drid, D.tDeliverOrder as orderTime, R.rating as rating
        FROM Rates R JOIN Delivers D USING (oid)) t
    WHERE (SELECT EXTRACT(MONTH FROM t.orderTime)) = month
    GROUP BY t.drid

    UNION
    
    SELECT DR.uid, 0, 0
    FROM DeliveryRiders DR
    WHERE DR.uid NOT IN (
        SELECT DISTINCT t.drid
        FROM (
            SELECT D.uid as drid, D.tDeliverOrder as orderTime
            FROM Rates R JOIN Delivers D USING (oid)) t
        WHERE (SELECT EXTRACT(MONTH FROM t.orderTime)) = month));

END;
$$ LANGUAGE 'plpgsql';

-- Get rider's average delivery time
DROP FUNCTION IF EXISTS getAvgDeliveryTime;
CREATE FUNCTION getAvgDeliveryTime(month integer)
 RETURNS TABLE(outputUid INTEGER, outputAvgDeliveryTime DOUBLE PRECISION)
AS $$
BEGIN

 RETURN QUERY (
    SELECT D.uid, AVG(DATE_PART('minute', D.tDeliverOrder::timestamp - D.tOrderPlaced::timestamp)) as avgTime
    FROM Delivers D
    WHERE (SELECT EXTRACT(MONTH FROM D.tDeliverOrder)) = month
    GROUP BY D.uid
    
    UNION

    SELECT DR.uid, 0
    FROM DeliveryRiders DR
    WHERE DR.uid NOT IN (
        SELECT DISTINCT D.uid
        FROM Delivers D
        WHERE EXTRACT(MONTH FROM D.tDeliverOrder) = month
    ));

END;
$$ LANGUAGE 'plpgsql';


-- Get rider monthly statistics
DROP FUNCTION IF EXISTS getRiderMonthlyStats;
CREATE FUNCTION getRiderMonthlyStats(month integer)
 RETURNS SETOF json 
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
     WITH riderSalary AS (SELECT * FROM getRiderTotalOrdersAndSalary(month)),
     riderDeliveryTime AS (SELECT* FROM getAvgDeliveryTime(month)),
     riderRatings as (SELECT * FROM getRiderRatings(month))
     SELECT t1.outputUid as uid, t1.outputOrder as numOfOrders, t1.outputSalary as salary,
     t1.outputAvgDeliveryTime as avgDeliveryTime, t1.outputNumOfRatings as numOfRatings, t1.outputAvgRatings as avgRating
     FROM (riderSalary NATURAL JOIN riderDeliveryTime NATURAL JOIN riderRatings) t1
) t;

END;
$$ LANGUAGE 'plpgsql';

-- Get orders for each hour for each delivery location
DROP FUNCTION IF EXISTS getDeliveryLocationStats;
CREATE FUNCTION getDeliveryLocationStats()
 RETURNS SETOF json 
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
     WITH ordersInDeliveryLocation AS (
         SELECT EXTRACT(HOUR FROM D.tOrderPlaced) AS hour, O.deliveryLocation
         FROM Delivers D NATURAL JOIN Orders O 
         GROUP BY (hour, deliveryLocation)
     )
     SELECT * from ordersInDeliveryLocation
    ) t;

END;
$$ LANGUAGE 'plpgsql';
