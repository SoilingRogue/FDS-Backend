DROP TABLE IF EXISTS FoodItems
CASCADE;
DROP TABLE IF EXISTS FoodCategories
CASCADE;
DROP TABLE IF EXISTS BelongsTo
CASCADE;
DROP TABLE IF EXISTS Restaurants
CASCADE;
DROP TABLE IF EXISTS Sells
CASCADE;
DROP TABLE IF EXISTS Promotions
CASCADE;
DROP TABLE IF EXISTS RestaurantPromotions
CASCADE;
DROP TABLE IF EXISTS FDSPromotions
CASCADE;
DROP TABLE IF EXISTS HasPromotions
CASCADE;
DROP TABLE IF EXISTS Orders
CASCADE;
DROP TABLE IF EXISTS OrderSummaries
CASCADE;
DROP TABLE IF EXISTS ConsistsOf
CASCADE;
DROP TABLE IF EXISTS Applies
CASCADE;
DROP TABLE IF EXISTS Users
CASCADE;
DROP TABLE IF EXISTS Managers
CASCADE;
DROP TABLE IF EXISTS RestaurantStaff
CASCADE;
DROP TABLE IF EXISTS Customers
CASCADE;
DROP TABLE IF EXISTS DeliveryRiders
CASCADE;
DROP TABLE IF EXISTS Places
CASCADE;
DROP TABLE IF EXISTS Delivers
CASCADE;
DROP TABLE IF EXISTS CurrentlyDelivering
CASCADE;
DROP TABLE IF EXISTS Reviews
CASCADE;
DROP TABLE IF EXISTS Rates
CASCADE;
DROP TABLE IF EXISTS LocationHistories
CASCADE;
DROP TABLE IF EXISTS PartTime
CASCADE;
DROP TABLE IF EXISTS FullTime
CASCADE;
DROP TABLE IF EXISTS Shifts
CASCADE;
DROP TABLE IF EXISTS Days
CASCADE;
DROP TABLE IF EXISTS WWS
CASCADE;
DROP TABLE IF EXISTS MWS
CASCADE;
DROP TABLE IF EXISTS HasShifts
CASCADE;
DROP TABLE IF EXISTS HasSchedule
CASCADE;

-- NEW VERSION --
-- Things to do:
-- Resolve all the comments in each table
-- Add missing attributes!!!
-- Decide which relation requires on DELETE CASCADE/ NOT NULL etc.

-- Food entities

CREATE TABLE FoodItems
(
    foodName VARCHAR(50),
    availability BIT,
    dailyStock INTEGER,
    currentStock INTEGER,
    price FLOAT,
    PRIMARY KEY (foodName)
);

CREATE TABLE FoodCategories
(
    categories VARCHAR(50),
    PRIMARY KEY (categories)
);

-- Food-Category relations

CREATE TABLE BelongsTo
(
    foodName VARCHAR(50) NOT NULL,
    categories VARCHAR(50) NOT NULL,
    PRIMARY KEY (foodName, categories),
    FOREIGN KEY (foodName) REFERENCES FoodItems,
    FOREIGN KEY (categories) REFERENCES FoodCategories
);

-- Restaurant entities

CREATE TABLE Restaurants
(
    rid SERIAL,
    rName VARCHAR(50) UNIQUE,
    minDeliveryCost FLOAT,
    PRIMARY KEY (rid)
);

-- Restaurant-Food relations

CREATE TABLE Sells
(
    rName VARCHAR(50) NOT NULL,
    foodName VARCHAR(50) NOT NULL,
    PRIMARY KEY (rName, foodName),
    FOREIGN KEY (rName) REFERENCES Restaurants(rname) ON DELETE CASCADE,
    FOREIGN KEY (foodName) REFERENCES FoodItems
);

-- Mock Data to test
insert into FoodItems(foodName, price) values('chicken rice', 4.5);
insert into FoodItems(foodName, price) values('steak', 10.0);
insert into FoodItems(foodName, price) values('bubble tea', 2.5);
insert into FoodItems(foodName, price) values('bak kut teh', 3.5);
insert into FoodItems(foodName, price) values('prata', 1.5);
insert into FoodItems(foodName, price) values('nasi lemak', 3.5);
insert into FoodItems(foodName, price) values('nasi padang', 3.8);
insert into FoodItems(foodName, price) values('nasi goreng', 4.2);
insert into FoodItems(foodName, price) values('murtabak', 3.6);

insert into foodcategories values('chinese');
insert into foodcategories values('western');
insert into foodcategories values('indian');
insert into foodcategories values('malay');
insert into foodcategories values('drinks');

insert into BelongsTo values('chicken rice', 'chinese');
insert into BelongsTo values('steak', 'western');
insert into BelongsTo values('bubble tea', 'drinks');
insert into BelongsTo values('prata', 'indian');
insert into BelongsTo values('bak kut teh', 'chinese');
insert into BelongsTo values('nasi padang', 'malay');
insert into BelongsTo values('nasi goreng', 'malay');
insert into BelongsTo values('murtabak', 'indian');

insert into Restaurants(rName) values('tian tian');
insert into Restaurants(rName) values('a1 bakkutteh place');
insert into Restaurants(rName) values('koi');
insert into Restaurants(rName) values('ameens');
insert into Restaurants(rName) values('prata house');
insert into Restaurants(rName) values('makcik shop');
insert into Restaurants(rName) values('astons');

insert into Sells values('tian tian', 'chicken rice');
insert into Sells values('astons', 'steak');
insert into Sells values('koi', 'bubble tea');
insert into Sells values('prata house', 'prata');
insert into Sells values('a1 bakkutteh place', 'bak kut teh');
insert into Sells values('makcik shop', 'nasi padang');
insert into Sells values('ameens', 'nasi goreng');
insert into Sells values('prata house', 'murtabak');

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
    type INTEGER,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES Promotions
);

CREATE TABLE FDSPromotions
(
    pid INTEGER,
    type INTEGER,
    PRIMARY KEY (pid),
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

CREATE TABLE Orders -- removed fds & res promo attributes since applies etc will link both entities tgt
(
    oid INTEGER,
    foodCost FLOAT NOT NULL,
    deliveryCost FLOAT NOT NULL,
    totalCost FLOAT NOT NULL,
    pointsUsed INTEGER,
    PRIMARY KEY (oid)
);

-- Order-Food relations

CREATE TABLE ConsistsOf
(
    oid INTEGER NOT NULL,
    foodName VARCHAR(50) NOT NULL,
    quantity INTEGER,
    PRIMARY KEY (oid, foodName),
    FOREIGN KEY (oid) REFERENCES Orders,
    FOREIGN KEY (foodName) REFERENCES FoodItems
);

-- Order-Promotion relations

CREATE TABLE Applies -- links both res & fds promos to order
(
    oid INTEGER,
    promo INTEGER,
    PRIMARY KEY (oid, promo),
    FOREIGN KEY (oid) REFERENCES Orders,
    FOREIGN KEY (promo) REFERENCES Promotions
);

-- Users entities - consists of FDSManager, RestStaff, Riders & Customers

CREATE TABLE Users
(
    uId SERIAL,
    email VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    PRIMARY KEY (uId)
);

CREATE TABLE Managers
(
    uId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE RestaurantStaff
(
    uId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE Customers
(
    uId INTEGER,
    rewardPoints INTEGER DEFAULT 0 CHECK (rewardPoints >= 0),
    creditCard CHAR(16) DEFAULT NULL,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE DeliveryRiders
(
    uId INTEGER,
    deliveryStatus BIT DEFAULT 0::BIT,
    commission FLOAT DEFAULT 0.0,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES Users ON DELETE CASCADE
);

-- Customer-order relations

CREATE TABLE Places
(
    cId INTEGER,
    oid INTEGER,
    PRIMARY KEY (cId, oid),
    FOREIGN KEY (cId) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Rider-order relations

CREATE TABLE Delivers -- MISSING t1,t2,t3,t4 -> forgot what those are
(
    uId INTEGER,
    oid INTEGER,
    PRIMARY KEY (oid),
    FOREIGN KEY (uId) REFERENCES DeliveryRiders,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Reviews & rates relations

CREATE TABLE Reviews
(
    uId INTEGER,
    oid INTEGER,
    reviewTxt VARCHAR(100),
    PRIMARY KEY (uId, oid),
    FOREIGN KEY (uId) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

CREATE TABLE Rates -- can consider having delivery id for delivers entity and use that ref here
(
    uId INTEGER,
    oid INTEGER,
    rating INTEGER,
    PRIMARY KEY (uId, oid),
    FOREIGN KEY (uId) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Delivers
);

-- Location entities

CREATE TABLE LocationHistories
(
    uId INTEGER NOT NULL,
    oid INTEGER NOT NULL,
    location VARCHAR(50),
    orderTime TIMESTAMP,
    PRIMARY KEY (oid),
    FOREIGN KEY (uId) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- DeliveryRiders entities - part time & full time

CREATE TABLE PartTime
(
    uId INTEGER,
    weeklyBaseSalary FLOAT,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES DeliveryRiders
);

CREATE TABLE FullTime
(
    uId INTEGER,
    monthlyBaseSalary FLOAT,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES DeliveryRiders
);

-- Work schedule entities - part time, full time, days & shifts
-- PTShift, WWS slightly diff from er diagram
CREATE TABLE PTShift
(
    day INTEGER,
    startTime INTEGER,
    endTime INTEGER,
    uId INTEGER,
    PRIMARY KEY (day, startTime, endTime, uId),
    FOREIGN KEY (uId) REFERENCES PartTime
);

CREATE TABLE FTShift
(
    sId INTEGER,
    start1 INTEGER NOT NULL,
    end1 INTEGER NOT NULL,
    start2 INTEGER NOT NULL,
    end2 INTEGER NOT NULL,
    PRIMARY KEY (sId)
);


CREATE TABLE WWS
(
    uId INTEGER,
    totalHours INTEGER,
    week INTEGER,
    PRIMARY KEY (uId, week),
    FOREIGN KEY (uId) REFERENCES PartTime
);

CREATE TABLE MWS
(
    uId INTEGER,
    month INTEGER,
    totalHours INTEGER,
    startDay INTEGER,
    endDay INTEGER,
    PRIMARY KEY (uId, month),
    FOREIGN KEY (uId) REFERENCES FullTime
);



-- NEED TO RELOOK THRU WORK SCHEDULES -> SLIGHTLY WRONG IMO
-- update on 21/4: changed form TIME Datatype to int + need to insert more data for monthly schedules
CREATE TABLE Shifts
(
    sid INTEGER,
    startTime int,
    endTime int,
    PRIMARY KEY (sid)
);

-- idk if needed - > see HasShifts relations in Work schedule relations
-- RMB to delete all references if not needed
CREATE TABLE Days
(
    day INTEGER,
    name VARCHAR(10),
    PRIMARY KEY (day)
);

CREATE TABLE WWS -- missing MakesUpOf relations
(
    uId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES PartTime
);

CREATE TABLE MWS -- missing MakesUpOf relations
(
    uId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES FullTime
);

-- Work schedule relations

-- Remember to delete day foreign key ref if days not needed
-- extra id present to link relation btw WWS & hasShifts
CREATE TABLE HasShifts
(
    id INTEGER,
    sid INTEGER NOT NULL,
    day INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (sid) REFERENCES Shifts,
    FOREIGN KEY (day) REFERENCES Days
);

-- Update on 21/4: Uid ref delivery riders instead
CREATE TABLE HasSchedule
(
    uId INTEGER,
    id INTEGER,
    PRIMARY KEY (uId, id),
    FOREIGN KEY (uId) REFERENCES DeliveryRiders,
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