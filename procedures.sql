-- Sequence for uid
CREATE SEQUENCE uidSequence START 1;


------------------------- Adding User Functionalities -----------------------------
/*
* Procedures:
* addUser(uid, email, password): Called by other add procedures.
* addCustomer():
* addDelieveryRider():
* addRestrauntStaff():
* addManager():
*/


-- Add User
CREATE OR REPLACE PROCEDURE addUser(newUid integer, 
	newEmail VARCHAR(50), newPassword VARCHAR(50)) 
AS $$
BEGIN

	INSERT INTO Users (uId, email, password) VALUES 
	(newUid, newEmail, newPassword);

END;
$$ LANGUAGE 'plpgsql';


-- Add Customer
-- Tag to a form that creates a customer
CREATE OR REPLACE PROCEDURE addCustomer(newEmail VARCHAR(50), 
	newPassword VARCHAR(50), newCreditCard char(16)) AS 
$$
DECLARE 
newUid integer := nextval('uidSequence');
BEGIN
	
	CALL addUser(newUid, newEmail, newPassword);

	INSERT INTO Customers (uId, rewardPoints, creditCard) 
	VALUES (newUid, DEFAULT, newCreditCard);

END;
$$ LANGUAGE 'plpgsql';



-- Add DeliveryRider
-- Tag to a form that creates a DeliveryRider
CREATE OR REPLACE PROCEDURE addDeliveryRider(newEmail VARCHAR(50), 
	newPassword VARCHAR(50)) AS 
$$
DECLARE 
newUid integer := nextval('uidSequence');
BEGIN
	
	CALL addUser(newUid, newEmail, newPassword);

	INSERT INTO DeliveryRiders (uId, deliverStatus, commission) 
	VALUES (newUid, DEFAULT, DEFAULT);

END;
$$ LANGUAGE 'plpgsql';


-- Add RestaurantStaff
-- Tag to a form that creates a RestrauntStaff
CREATE OR REPLACE PROCEDURE addRestrauntStaff(newEmail VARCHAR(50), 
	newPassword VARCHAR(50)) AS 
$$
DECLARE 
newUid integer := nextval('uidSequence');
BEGIN
	
	CALL addUser(newUid, newEmail, newPassword);

	INSERT INTO RestrauntStaff (uId) 
	VALUES (newUid);

END;
$$ LANGUAGE 'plpgsql';

-- Add FDSManager
-- Tag to a form that creates a FDSManager
CREATE OR REPLACE PROCEDURE addManager(newEmail VARCHAR(50), 
	newPassword VARCHAR(50)) AS 
$$
DECLARE 
newUid integer := nextval('uidSequence');
BEGIN
	
	CALL addUser(newUid, newEmail, newPassword);

	INSERT INTO Managers (uId) 
	VALUES (newUid);

END;
$$ LANGUAGE 'plpgsql';

-------------------------------------------------------------------