-- Sequence for uid
-- DROP SEQUENCE IF EXISTS uidSequence;
-- CREATE SEQUENCE uidSequence START 1;

------------------------- Adding User Functionalities -----------------------------
/*
* Functions:
* addUser(uid, email, password): Called by other add functions.
* addCustomer():
* addDelieveryRider():
* addRestaurantStaff():
* addFdsManager():
*/

-- Add User
DROP FUNCTION IF EXISTS addUser;
CREATE FUNCTION addUser(newEmail VARCHAR(50), newPassword VARCHAR(50))
 RETURNS setof integer
AS $$
BEGIN

 RETURN QUERY INSERT INTO Users (email, password) VALUES 
 (newEmail, newPassword)
 RETURNING uid;

END;
$$ LANGUAGE 'plpgsql';


-- Add Customer
-- Tag to a form that creates a customer
DROP FUNCTION IF EXISTS addCustomer;
CREATE FUNCTION addCustomer(newEmail VARCHAR(50), 
 newPassword VARCHAR(50))
 RETURNS SETOF json AS
$$
DECLARE 
newUid integer;
BEGIN
 
 SELECT addUser(newEmail, newPassword) into newUid;

 RETURN QUERY INSERT INTO Customers (uId, rewardPoints, creditCard) 
 VALUES (newUid, DEFAULT, DEFAULT)
 RETURNING json_build_object('uid', uid, 'rewardPoints', rewardPoints, 'creditCard', creditCard);

END;
$$ LANGUAGE 'plpgsql';


-- Add DeliveryRider
-- Tag to a form that creates a DeliveryRider
DROP FUNCTION IF EXISTS addDeliveryRider;
CREATE FUNCTION addDeliveryRider(newEmail VARCHAR(50), 
	newPassword VARCHAR(50))
    RETURNS SETOF json AS 
$$
DECLARE 
newUid integer;
BEGIN
	
    SELECT addUser(newEmail, newPassword) into newUid;

    RETURN QUERY INSERT INTO DeliveryRiders (uId, deliveryStatus, commission) 
	VALUES (newUid, DEFAULT, DEFAULT)
    RETURNING json_build_object('uid', uid, 'deliveryStatus', deliveryStatus, 'commission', commission);

END;
$$ LANGUAGE 'plpgsql';

-- Add RestaurantStaff
-- Tag to a form that creates a RestaurantStaff
DROP FUNCTION IF EXISTS addRestaurantStaff;
CREATE FUNCTION addRestaurantStaff(newEmail VARCHAR(50), 
	newPassword VARCHAR(50))
    RETURNS SETOF json AS 
$$
DECLARE 
newUid integer;
BEGIN

    SELECT addUser(newEmail, newPassword) into newUid;

    RETURN QUERY INSERT INTO RestaurantStaff (uId) 
	    VALUES (newUid)
        RETURNING json_build_object('uid', uid);
        
END;
$$ LANGUAGE 'plpgsql';

-- Add FDSManager
-- Tag to a form that creates a FDSManager
DROP FUNCTION IF EXISTS addFdsManager;
CREATE FUNCTION addFdsManager(newEmail VARCHAR(50), 
	newPassword VARCHAR(50))
RETURNS SETOF json AS 
$$
DECLARE 
newUid integer;
BEGIN
	
    SELECT addUser(newEmail, newPassword) into newUid;

    RETURN QUERY 
    INSERT INTO Managers (uId) 
	VALUES (newUid)
    RETURNING json_build_object('uid', uid);

END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------