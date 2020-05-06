DROP TABLE IF EXISTS FoodItems
CASCADE;
DROP TABLE IF EXISTS FoodCategories
CASCADE;
DROP TABLE IF EXISTS BelongsTo
CASCADE;
DROP TABLE IF EXISTS Restaurants
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



-- Restaurant entities

CREATE TABLE Restaurants
(
    rid SERIAL,
    rName VARCHAR(50),
    minOrderCost FLOAT CHECK (minOrderCost >= 0),
    PRIMARY KEY (rid)
);

-- Food entities

CREATE TABLE FoodItems
(
    rid INTEGER,
    foodName VARCHAR(50),
    availability INTEGER,
    dailyStock INTEGER CHECK (dailyStock >= 0),
    currentStock INTEGER CHECK (currentStock <= dailyStock AND currentStock >= 0),
    price FLOAT CHECK (price >= 0),
    PRIMARY KEY (rid, foodName),
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE
);

CREATE TABLE FoodCategories
(
    categories VARCHAR(50),
    PRIMARY KEY (categories)
);

-- Food-Category relations

CREATE TABLE BelongsTo
(
    rid INTEGER NOT NULL,
    foodName VARCHAR(50) NOT NULL,
    categories VARCHAR(50) NOT NULL,
    PRIMARY KEY (rid, foodName, categories),
    FOREIGN KEY (rid, foodName) REFERENCES FoodItems ON DELETE CASCADE,
    FOREIGN KEY (categories) REFERENCES FoodCategories
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
    FOREIGN KEY (pid) REFERENCES Promotions ON DELETE CASCADE
);

CREATE TABLE PriceTimeOrderPromotions
(
    pid INTEGER,
    discountPercentage FLOAT CHECK (discountPercentage >= 0),
    baseAmount FLOAT CHECK (baseAmount >= 0),
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions ON DELETE CASCADE
);

CREATE TABLE PriceTimeItemPromotions
(
    pid INTEGER,
    discountPercentage FLOAT CHECK (discountPercentage >= 0),
    baseAmount FLOAT CHECK (baseAmount >= 0),
    rid INTEGER NOT NULL,
    item VARCHAR(50),
    PRIMARY KEY (pid, item),
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions ON DELETE CASCADE,
    FOREIGN KEY (rid, item) REFERENCES FoodItems ON DELETE CASCADE
);

CREATE TABLE FDSPromotions
(
    pid INTEGER,
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES Promotions ON DELETE CASCADE
);

CREATE TABLE FirstOrderPromotions
(
    pid INTEGER,
    discountPercentage FLOAT CHECK (discountPercentage >= 0),
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES FDSPromotions ON DELETE CASCADE
);

CREATE TABLE DeliveryPromotions
(
    pid INTEGER,
    startDate DATE,
    endDate DATE,
    discountPercentage FLOAT CHECK (discountPercentage >= 0),
    baseAmount FLOAT CHECK (baseAmount >= 0),
    PRIMARY KEY (pid),
    FOREIGN KEY (pid) REFERENCES FDSPromotions ON DELETE CASCADE
);

-- Restaurant-Promotion relations

CREATE TABLE HasPromotions
(
    rid INTEGER NOT NULL,
    pid INTEGER NOT NULL,
    PRIMARY KEY (rid, pid),
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE,
    FOREIGN KEY (pid) REFERENCES RestaurantPromotions ON DELETE CASCADE
);

-- Order entities

CREATE TABLE Orders -- removed fds & res promo attributes since applies etc will link both entities tgt
(
    oid SERIAL,
    foodCost FLOAT NOT NULL CHECK (foodCost >= 0),
    deliveryCost FLOAT NOT NULL CHECK (deliveryCost >= 0),
    totalCost FLOAT NOT NULL CHECK (totalCost >= 0),
    pointsUsed INTEGER CHECK (pointsUsed >= 0),
    ordered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deliveryLocation TEXT,
    PRIMARY KEY (oid)
);

-- Order-Food relations

CREATE TABLE ConsistsOf
(
    oid INTEGER NOT NULL,
    rid INTEGER,
    foodName VARCHAR(50) NOT NULL,
    quantity INTEGER CHECK (quantity > 0),
    PRIMARY KEY (oid, foodName),
    FOREIGN KEY (oid) REFERENCES Orders,
    FOREIGN KEY (rid, foodName) REFERENCES FoodItems,
    FOREIGN KEY (rid) REFERENCES RESTAURANTS
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
    uid SERIAL,
    email VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    PRIMARY KEY (uid)
);

CREATE TABLE Managers
(
    uid INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE RestaurantStaff
(
    uid INTEGER,
    rId INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE,
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE
);

CREATE TABLE Customers
(
    uid INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    rewardPoints INTEGER DEFAULT 0 CHECK (rewardPoints >= 0),
    creditCard CHAR(16) DEFAULT NULL,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE DeliveryRiders
(
    uid INTEGER,
    -- 0 => Avaliable, 1 => Assigned Order, 2 => Depart To Rest, 3 => Arrive At Rest, 4 => Departing From Rest, 0 => Order Delivered
    deliveryStatus INTEGER DEFAULT 0, 
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

-- Customer-order relations

CREATE TABLE Places
(
    uid INTEGER,
    oid INTEGER,
    PRIMARY KEY (uid, oid),
    FOREIGN KEY (uid) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Rider-order relations

CREATE TABLE Delivers
(
    uid INTEGER NOT NULL,
    oid INTEGER NOT NULL,
    tOrderPlaced TIMESTAMP DEFAULT NOW(),
    tDepartToRest TIMESTAMP,
    tArriveAtRest TIMESTAMP,
    tDepartFromRest TIMESTAMP,
    tDeliverOrder TIMESTAMP,
    PRIMARY KEY (oid),
    FOREIGN KEY (uid) REFERENCES DeliveryRiders,
    FOREIGN KEY (oid) REFERENCES Orders
);

-- Reviews & rates relations

CREATE TABLE Reviews
(
    uid INTEGER,
    oid INTEGER,
    reviewTxt VARCHAR(100),
    PRIMARY KEY (uid, oid),
    FOREIGN KEY (uid) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Orders
);

CREATE TABLE Rates -- can consider having delivery id for delivers entity and use that ref here
(
    uid INTEGER,
    oid INTEGER,
    rating INTEGER CHECK (rating >= 0 AND rating <= 5),
    PRIMARY KEY (uid, oid),
    FOREIGN KEY (uid) REFERENCES Customers,
    FOREIGN KEY (oid) REFERENCES Delivers
);

-- DeliveryRiders entities - part time & full time

CREATE TABLE PartTime
(
    uid INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES DeliveryRiders ON DELETE CASCADE
);

CREATE TABLE FullTime
(
    uid INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES DeliveryRiders ON DELETE CASCADE
);

-- Work schedule entities - part time, full time, days & shifts
-- Need to look thru MWS and WWS

CREATE TABLE PTShift
(
    day INTEGER CHECK (day >= 1 AND DAY <= 7),
    startTime INTEGER CHECK (startTime >= 10 AND startTime <= 21 AND startTime < endTime AND startTime + 4 >= endTime),
    endTime INTEGER CHECK (endTime > 10 AND endTime <= 22),
    uid INTEGER,
    PRIMARY KEY (day, startTime, endTime, uid),
    FOREIGN KEY (uid) REFERENCES PartTime ON DELETE CASCADE
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
    uid INTEGER,
    week INTEGER,
    PRIMARY KEY (uid, week),
    FOREIGN KEY (uid) REFERENCES PartTime ON DELETE CASCADE
);

CREATE TABLE MWS
(
    uid INTEGER,
    month INTEGER CHECK (month >= 1 AND month <= 12),
    startDay INTEGER CHECK (startDay >= 1 AND startDay <= 7),
    endDay INTEGER CHECK (endDay >= 1 AND endDay <= 7),
    PRIMARY KEY (uid, month),
    FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE
);

-- remember to update this table when fttimescheduling is edited or vice versa
CREATE TABLE DayCombinations
(
    startDay INTEGER CHECK (startDay >= 1 AND startDay <= 7),
    endDay INTEGER CHECK (endDay >= 1 AND endDay <= 7),
    uid INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE
);

-- remember to update this table when daycombinations is edited or vice versa
CREATE TABLE FullTimeScheduling
(
    uid INTEGER,
    day INTEGER CHECK (day >= 1 AND day <= 7),
    shift INTEGER,
    PRIMARY KEY (uid, day, shift),
    FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE,
    FOREIGN KEY (shift) REFERENCES FTShift
);