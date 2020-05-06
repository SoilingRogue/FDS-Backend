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
 RETURNS SETOF integer
AS $$
BEGIN

 RETURN QUERY SELECT count(*) FROM ORDERS;

END;
$$ LANGUAGE 'plpgsql';


-- Get total cost of all orders
DROP FUNCTION IF EXISTS getTotalCost;
CREATE FUNCTION getTotalCost()
 RETURNS SETOF integer
AS $$
BEGIN

 RETURN QUERY SELECT sum(totalCost) FROM ORDERS;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of customers
DROP FUNCTION IF EXISTS getTotalCustomers;
CREATE FUNCTION getTotalCustomers()
 RETURNS SETOF integer
AS $$
BEGIN

 RETURN QUERY SELECT count(*) FROM Customers;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of orders in a month
DROP FUNCTION IF EXISTS getTotalMonthlyOrder;
CREATE FUNCTION getTotalMonthlyOrder(month integer)
 RETURNS SETOF bigint
AS $$
BEGIN

 RETURN QUERY SELECT count(*) 
 FROM ORDERS O 
 WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month;

END;
$$ LANGUAGE 'plpgsql';


-- Get total cost of orders in a month
DROP FUNCTION IF EXISTS getTotalMonthlyCost;
CREATE FUNCTION getTotalMonthlyCost(month integer)
 RETURNS SETOF double precision
AS $$
BEGIN

 RETURN QUERY SELECT sum(totalCost) 
 FROM ORDERS O 
 WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month;

END;
$$ LANGUAGE 'plpgsql';


-- Get total number of new customers in a month
DROP FUNCTION IF EXISTS getTotalMonthlyNewCustomer;
CREATE FUNCTION getTotalMonthlyNewCustomer(month integer)
 RETURNS SETOF bigint
AS $$
BEGIN

 RETURN QUERY SELECT count(*) 
 FROM Customers C
 WHERE (SELECT EXTRACT(MONTH FROM C.created_at)) = month;

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

/*
-- Get rider monthly statistics
DROP FUNCTION IF EXISTS getCustMonthlyStats;
CREATE FUNCTION getRiderMonthlyStats(month integer)
 RETURNS SETOF json 
AS $$
BEGIN

 RETURN QUERY SELECT array_to_json(array_agg(row_to_json(t))) FROM (
    SELECT count(*) AS ordersDelivered, sum(R.totalCost) AS hoursWorked, salary, avgDeliverTime, numOfRatings, avgRating
    FROM Orders O NATURAL JOIN Places P
    WHERE (SELECT EXTRACT(MONTH FROM O.ordered_at)) = month
    GROUP BY P.cid
    ) t;

END;
$$ LANGUAGE 'plpgsql';

*/







