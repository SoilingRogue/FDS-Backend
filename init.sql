DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS RestaurantStaff CASCADE;
DROP TABLE IF EXISTS Managers CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS DeliveryRiders CASCADE;
DROP TABLE IF EXISTS Food CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Sells CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS OrderArchive CASCADE;
DROP TABLE IF EXISTS Promotions CASCADE;

CREATE TABLE Users
(
    email VARCHAR(50),
    password VARCHAR(50),
    PRIMARY KEY (email)
);

CREATE TABLE RestaurantStaff
(
    rEmail VARCHAR(50),
    PRIMARY KEY (rEmail),
    FOREIGN KEY (rEmail) REFERENCES Users
);

CREATE TABLE Managers
(
    mEmail VARCHAR(50),
    PRIMARY KEY (mEmail),
    FOREIGN KEY (mEmail) REFERENCES Users
);

CREATE TABLE Customers
(
    cEmail VARCHAR(50),
    reward INTEGER,
    creditCard INTEGER,
    --Credit card has to have certain length
    lastOrder INTEGER,
    PRIMARY KEY (cEmail),
    FOREIGN KEY (cEmail) REFERENCES Users
);

CREATE TABLE DeliveryRiders
(
    --WIP
    dEmail VARCHAR(50),
    salary FLOAT,
    deliveryStatus VARCHAR(20),
    numDelivered INTEGER,
    PRIMARY KEY (dEmail),
    FOREIGN KEY (dEmail) REFERENCES Users
);

CREATE TABLE Food
(
    fName VARCHAR(50),
    type VARCHAR(20),
    PRIMARY KEY (fName)
);

CREATE TABLE Restaurants
(
    rid INTEGER,
    name VARCHAR(50),
    minDeliveryCost FLOAT,
    PRIMARY KEY (rid)
);

-- yeotong says kiv
CREATE TABLE Sells
(
    rid INTEGER NOT NULL,
    fName VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,

    PRIMARY KEY (rid, fName),
    FOREIGN KEY (rid) REFERENCES Restaurants ON DELETE CASCADE,
    FOREIGN KEY (fName) REFERENCES Food
);

CREATE TABLE Orders -- WIP
(
    oid INTEGER NOT NULL
    -- PRIMARY KEY (oid, rid, cEmail, dEmail, orderDate)
);

CREATE TABLE OrderArchive --WIP
(
    oid INTEGER,
    rid INTEGER NOT NULL,
    cEmail VARCHAR(50) NOT NULL,
    dEmail VARCHAR(50) NOT NULL,
    totalCost FLOAT,
    location VARCHAR(50),
    paymentType VARCHAR(20),
    orderDate DATE,
    PRIMARY KEY (oid),
    FOREIGN KEY (rid) REFERENCES Restaurants,
    FOREIGN KEY (cEmail) REFERENCES Customers,
    FOREIGN KEY (dEmail) REFERENCES DeliveryRiders
);

CREATE TABLE Promotions
(
    -- WIP
    pid INTEGER NOT NULL,
    startDate DATE,
    endDate DATE,
    description VARCHAR(50),
    discountAmt FLOAT,
    PRIMARY KEY (pid)
);
