-- NEW VERSION --
-- Things to do:
-- Resolve all the comments in each table
-- Add missing attributes!!!
-- Decide which relation requires on DELETE CASCADE/ NOT NULL etc.

-- Food entities

CREATE TABLE FoodItems
(
    foodName VARCHAR(50),
    -- missing availability cause idk what that is
    dailyStock INTEGER,
    currentStock INTEGER,
    price FLOAT,
    PRIMARY KEY (foodName)
);

CREATE TABLE FoodCategories -- might be unnecessary
(
    categories VARCHAR(50),
    PRIMARY KEY (categories)
);

-- Food relations

CREATE TABLE BelongsTo
(
    foodName VARCHAR(50) NOT NULL,
    categories VARCHAR(50) NOT NULL,
    PRIMARY KEY (foodName, categories),
    FOREIGN KEY (foodName) REFERENCES FoodItems,
    FOREIGN KEY (categories) REFERENCES FoodCategories,
);

-- Restaurant entities

CREATE TABLE Restaurants -- can discuss whether minDeliveryCost belongs here or if theres a better place
(
    rid INTEGER,
    rName VARCHAR(50),
    minDeliveryCost FLOAT,
    PRIMARY KEY (rid)
);

-- Restaurant-Food relations

CREATE TABLE Sells
(
    rid INTEGER NOT NULL,
    foodName VARCHAR(50) NOT NULL,
    PRIMARY KEY (rid, foodName),
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE,
    FOREIGN KEY (foodName) REFERENCES FoodItems
);

-- Promotion entities

CREATE TABLE Promotions
(
    pid INTEGER,
    startDate DATE,
    endDate DATE,
    PRIMARY KEY (pid)
);

CREATE TABLE RestaurantPromotions
(
    pid INTEGER,
    amount FLOAT,
    -- missing condition -> boolean or what??
    -- missing type -> not sure what this is + use int or varchar ???
    FOREIGN KEY (pid) REFERENCES Promotions
);

CREATE TABLE FDSPromotions
(
    pid INTEGER,
    -- missing type -> use int or varchar ???
    FOREIGN KEY (pid) REFERENCES Promotions
);

-- Restaurant-Promotion relations

CREATE TABLE HasPromotions
(
    rid INTEGER NOT NULL,
    pid INTEGER NOT NULL,
    PRIMARY KEY (rid, pid),
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE,
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions
);

-- Order entities

CREATE TABLE Orders --Not sure on promos -> supposed to contain the promoid/ discount price/ etc?
(
    oid INTEGER,
    foodCost FLOAT NOT NULL,
    deliveryCost FLOAT NOT NULL,
    totalCost FLOAT NOT NULL,
    pointsUsed INTEGER,
    fdsPromo INTEGER,
    resPromo INTEGER,
    PRIMARY KEY (oid)
);

CREATE TABLE OrderSummaries -- Useless for now
(
    oid INTEGER,
    PRIMARY KEY (oid)
);


-- Order-Food relations

CREATE TABLE ConsistsOf -- Slight difference from the ER diagram - foodName used instead of rid
(
    oid INTEGER NOT NULL,
    foodName VARCHAR(50) NOT NULL,
    PRIMARY KEY (oid, foodName),
    FOREIGN KEY (oid) REFERENCES Orders,
    FOREIGN KEY (foodName) REFERENCES FoodItems
);

-- Order-Promotion relations

-- Missing Order-Restaurant promotions

CREATE TABLE Applies
(
    oid INTEGER,
    fdsPromo INTEGER,
    PRIMARY KEY (oid, fdsPromo),
    FOREIGN KEY (oid) REFERENCES Orders,
    FOREIGN KEY (fdsPromo) REFERENCES FDSPromotions
);

-- Users entities - consists of FDSManager, RestStaff, Riders & Customers

CREATE TABLE Users -- are we still keeping email & password ?
(
    email VARCHAR(50),
    password VARCHAR(50),
    PRIMARY KEY (email)
);

CREATE TABLE FDSManagers
(
    mEmail VARCHAR(50),
    PRIMARY KEY (mEmail),
    FOREIGN KEY (mEmail) REFERENCES Users
);

CREATE TABLE RestaurantStaff
(
    rEmail VARCHAR(50),
    PRIMARY KEY (rEmail),
    FOREIGN KEY (rEmail) REFERENCES Users
);

-- Customers missing locHistory ref, but locRef references customers so its ok right?
-- Add in other missing attibutes such as creditcard etc if needed
CREATE TABLE Customers
(
    cEmail VARCHAR(50),
    rewardPoints INTEGER,
    PRIMARY KEY (cEmail),
    FOREIGN KEY (cEmail) REFERENCES Users
);

-- Add in other missing attibutes such as deliverystatus etc if needed
CREATE TABLE Riders
(
    rEmail VARCHAR(50),
    PRIMARY KEY (rEmail),
    FOREIGN KEY (rEmail) REFERENCES Users
);

-- Customer-order relations

CREATE TABLE PLACES
(
    cEmail VARCHAR(50),
    oid INTEGER,
    PRIMARY KEY (cEmail, oid),
    FOREIGN KEY (cEmail) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Rider-order relations

CREATE TABLE Delivers -- MISSING t1,t2,t3,t4 -> forgot what those are
(
    rEmail VARCHAR(50),
    oid INTEGER,
    PRIMARY KEY (rEmail, oid),
    FOREIGN KEY (rEmail) REFERENCES Riders,
    FOREIGN KEY (oid) REFERENCES Orders
);

CREATE TABLE CurrentlyDelivering
(
    rEmail VARCHAR(50),
    oid INTEGER,
    PRIMARY KEY (rEmail, oid),
    FOREIGN KEY (rEmail) REFERENCES Riders,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Reviews & rates relations

CREATE TABLE Reviews
(
    cEmail VARCHAR(50),
    oid INTEGER,
    reviewTxt VARCHAR(100),
    PRIMARY KEY (cEmail, oid),
    FOREIGN KEY (cEmail) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

CREATE TABLE Rates -- diff from ER, currently linked to orders and not deliveries
(
    cEmail VARCHAR(50),
    oid INTEGER,
    rating INTEGER,
    PRIMARY KEY (cEmail, oid),
    FOREIGN KEY (cEmail) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Location entities

-- Contains the 3 most recent locations right? locations all null should also be valid
-- OMITTED Contains relations for locationhistory-location due to the foreign key ref below
-- Same for has relations for Customer-LocationHistories
CREATE TABLE LocationHistories
(
    cid INTEGER,
    address1 VARCHAR(50),
    address2 VARCHAR(50),
    address3 VARCHAR(50),
    PRIMARY KEY (cid),
    FOREIGN KEY (cid) REFERENCES CUstomers,
    FOREIGN KEY (address1) REFERENCES Locations,
    FOREIGN KEY (address2) REFERENCES Locations,
    FOREIGN KEY (address3) REFERENCES Locations
);

CREATE TABLE Locations -- is there even a need for this table anymore given the above entity?
(
    address VARCHAR(50),
    PRIMARY KEY (address)
);

-- Riders entities - part time & full time

-- shifted commissions into riders instead
CREATE TABLE PartTime
(
    rid INTEGER,
    weeklyBaseSalary FLOAT,
    -- Primary key rid or (rid, weeklysalary) ? -> makes more sense for below imo cause discriminatory of every rider diff base
    PRIMARY KEY (rid),
    FOREIGN KEY (rid) REFERENCES Riders
);

CREATE TABLE FullTime
(
    rid INTEGER,
    monthlyBaseSalary FLOAT,
    -- Same concern as PartTime
    PRIMARY KEY (rid),
    FOREIGN KEY (rid) REFERENCES Riders
);

-- Work schedule entities - part time, full time, days & shifts

-- NEED TO RELOOK THRU WORK SCHEDULES -> SLIGHTLY WRONG IMO
CREATE TABLE Shifts
(
    sid INTEGER,
    startTime TIME(0),
    endTime TIME(0),
    PRIMARY KEY (sid)
);

-- idk if needed - > see HasShifts relations in Work schedule relations
-- RMB to delete all references if not needed
CREATE TABLE Days
(
    day INTEGER,
    name VARCHAR(10),
    PRIMARY KEY (day, name)
);

CREATE TABLE WWS -- missing MakesUpOf relations
(
    rid INTEGER,
    FOREIGN KEY (rid) REFERENCES PartTime
);

CREATE TABLE MWS -- missing MakesUpOf relations
(
    rid INTEGER,
    FOREIGN KEY (rid) REFERENCES FullTime
);

-- Work schedule relations

-- Remember to delete day foreign key ref if days not needed
-- extra id present to link relation btw WWS & hasShifts
CREATE TABLE HasShifts
(
    id INTEGER,
    sid INTEGER NOT NULL,
    day INTEGER ,
    PRIMARY KEY (id),
    FOREIGN KEY (sid) REFERENCES Shifts,
    FOREIGN KEY (day) REFERENCES Days
);

CREATE TABLE HasSchedule
(
    rid INTEGER,
    id INTEGER,
    PRIMARY KEY (rid, id),
    FOREIGN KEY (rid) REFERENCES WWS,
    FOREIGN KEY (id) REFERENCES HasShifts
);





-- OLD Version

-- CREATE TABLE Users
-- (
--     email VARCHAR(50),
--     password VARCHAR(50),
--     PRIMARY KEY (email)
-- );

-- CREATE TABLE RestaurantStaffs
-- (
--     rEmail VARCHAR(50),
--     PRIMARY KEY (rEmail),
--     FOREIGN KEY (rEmail) REFERENCES Users
-- );

-- CREATE TABLE Managers
-- (
--     mEmail VARCHAR(50),
--     PRIMARY KEY (mEmail),
--     FOREIGN KEY (mEmail) REFERENCES Users
-- );

-- CREATE TABLE Customers
-- (
--     cEmail INTEGER,
--     reward INTEGER,
--     creditCard INTEGER,
--     --Credit card has to have certain length
--     lastOrder INTEGER,
--     PRIMARY KEY (cEmail),
--     FOREIGN KEY (cEmail) REFERENCES Users,
--     FOREIGN KEY (lastOrder) REFERENCES OrderArchive
-- );

-- CREATE TABLE DeliveryRiders
-- (
--     --WIP
--     dEmail VARCHAR(50),
--     salary FLOAT,
--     deliveryStatus VARCHAR(20),
--     numDelivered INTEGER,
--     PRIMARY KEY (dEmail),
--     FOREIGN KEY (dEmail) REFERENCES Users
-- );

-- CREATE TABLE Food
-- (
--     fName VARCHAR(50),
--     type VARCHAR(20),
--     PRIMARY KEY (fName)
-- );

-- CREATE TABLE Restaurants
-- (
--     rid INTEGER,
--     name VARCHAR(50),
--     minDeliveryCost FLOAT,
--     PRIMARY KEY (rid)
-- );

-- -- yeotong says kiv
-- CREATE TABLE Sells
-- (
--     rid INTEGER NOT NULL,
--     fName VARCHAR(50) NOT NULL,
--     PRIMARY KEY (rid, fid),
--     FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE,
--     FOREIGN KEY (fName) REFERENCES Food
-- );

-- CREATE TABLE Orders -- WIP
-- (
--     oid INTEGER NOT NULL,
--     PRIMARY KEY (oid, rid, cEmail, dEmail, orderDate)
-- );

-- CREATE TABLE OrderArchive --WIP
-- (
--     oid INTEGER,
--     rid INTEGER NOT NULL,
--     cEmail VARCHAR(50) NOT NULL,
--     dEmail VARCHAR(50) NOT NULL,
--     totalCost FLOAT,
--     location VARCHAR(50),
--     paymentType VARCHAR(20),
--     orderDate DATE,
--     PRIMARY KEY (oid),
--     FOREIGN KEY (rid) REFERENCES Restaurants,
--     FOREIGN KEY (cEmail) REFERENCES Customers,
--     FOREIGN KEY (dEmail) REFERENCES DeliveryRiders
-- );

-- CREATE TABLE Promotions
-- (
--     -- WIP
--     pid INTEGER NOT NULL,
--     startDate DATE,
--     endDate DATE,
--     description VARCHAR(50),
--     discountAmt FLOAT,
--     PRIMARY KEY (pid)
-- );