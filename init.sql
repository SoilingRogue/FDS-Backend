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
DROP TABLE IF EXISTS PriceTimeItemPromotions
CASCADE;
DROP TABLE IF EXISTS PriceTimeOrderPromotions
CASCADE;
DROP TABLE IF EXISTS FDSPromotions
CASCADE;
DROP TABLE IF EXISTS FirstOrderPromotions
CASCADE;
DROP TABLE IF EXISTS DeliveryPromotions
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
DROP TABLE IF EXISTS PartTime
CASCADE;
DROP TABLE IF EXISTS FullTime
CASCADE;
DROP TABLE IF EXISTS PTShift
CASCADE;
DROP TABLE IF EXISTS FTShift
CASCADE;
DROP TABLE IF EXISTS WWS
CASCADE;
DROP TABLE IF EXISTS MWS
CASCADE;
DROP TABLE IF EXISTS FullTimeScheduling
CASCADE;
DROP TABLE IF EXISTS DayCombinations
CASCADE;

-- NEW VERSION --
-- Things to do:
-- Resolve all the comments in each table
-- Add missing attributes!!!
-- Decide which relation requires on DELETE CASCADE/ NOT NULL etc.

-- Food entities

CREATE TABLE FoodItems
(
    rid INTEGER,
    foodName VARCHAR(50),
    availability INTEGER,
    dailyStock INTEGER,
    currentStock INTEGER,
    price FLOAT,
    PRIMARY KEY (rid, foodName),
    FOREIGN KEY (rid) REFERENCES Restaurants
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

-- Promotion entities

CREATE TABLE Promotions
(
    pid INTEGER,
    PRIMARY KEY (pid)
);

CREATE TABLE RestaurantPromotions
(
    pid INTEGER,
    startDate DATE,
    endDate DATE,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES Promotions
);

CREATE TABLE PriceTimeOrderPromotions
(
    pid INTEGER,
    discountPercentage FLOAT,
    baseAmount FLOAT,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions
);

CREATE TABLE PriceTimeItemPromotions
(
    pid INTEGER,
    discountPercentage FLOAT,
    baseAmount FLOAT,
    item VARCHAR(50),
    PRIMARY KEY (pid, item),
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions,
    FOREIGN KEY (item) REFERENCES FoodItems
);

CREATE TABLE FDSPromotions
(
    pid INTEGER,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES Promotions
);

CREATE TABLE FirstOrderPromotions
(
    pid INTEGER,
    discountPercentage FLOAT,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES FDSPromotions
);

CREATE TABLE DeliveryPromotions
(
    pid INTEGER,
    startDate DATE,
    endDate DATE,
    discountPercentage FLOAT,
    baseAmount FLOAT,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES FDSPromotions
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
    order_at TIMESTAMP NOT NULL DEFAULT NOW(),
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
    rId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES Users ON DELETE CASCADE,
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE
);

CREATE TABLE Customers
(
    uId INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
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
-- Need to look thru MWS and WWS

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

-- remember to update this table when fttimescheduling is edited or vice versa
CREATE TABLE DayCombinations
(
    startDay INTEGER,
    endDay INTEGER,
    uId INTEGER,
    PRIMARY KEY (uId),
    FOREIGN KEY (uId) REFERENCES FullTime
);

-- remember to update this table when daycombinations is edited or vice versa
CREATE TABLE FullTimeScheduling
(
    uId INTEGER,
    day INTEGER,
    shift INTEGER,
    PRIMARY KEY (uId, day, shift),
    FOREIGN KEY (uId) REFERENCES FullTime,
    FOREIGN KEY (shift) REFERENCES FTShift
);