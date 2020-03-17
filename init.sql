CREATE TABLE Food
(
    fid INTEGER NOT NULL,
    name VARCHAR(50),
    type VARCHAR(20),
    PRIMARY KEY (fid)
);

CREATE TABLE Restaurants
(
    rid INTEGER NOT NULL,
    minDeliveryCost FLOAT,
    PRIMARY KEY (rid)
);

-- yeotong says kiv
CREATE TABLE Sells
(
    rid INTEGER NOT NULL,
    fid INTEGER NOT NULL,
    PRIMARY KEY (rid, fid),
    FOREIGN KEY (rid) REFERENCES Restaurants,
    FOREIGN KEY (fid) REFERENCES Food
);

CREATE TABLE Customers
(
    cid INTEGER NOT NULL,
    reward INTEGER,
    creditCard INTEGER,
    --Credit card has to have certain length
    lastOrder INTEGER,
    PRIMARY KEY (cid),
    FOREIGN KEY (lastOrder) REFERENCES OrderArchive
);

CREATE TABLE Orders -- WIP
(
    oid INTEGER NOT NULL,
    PRIMARY KEY (oid, rid, cid, did, orderDate)
);

CREATE TABLE OrderArchive --WIP
(
    oid INTEGER NOT NULL,
    rid INTEGER NOT NULL,
    cid INTEGER NOT NULL,
    did INTEGER NOT NULL,
    totalCost FLOAT,
    location VARCHAR(50),
    paymentType VARCHAR(20),
    orderDate DATE,
    PRIMARY KEY (oid),
    FOREIGN KEY (rid) REFERENCES Restaurants,
    FOREIGN KEY (cid) REFERENCES Customers,
    FOREIGN KEY (did) REFERENCES DeliveryRiders
);

CREATE TABLE DeliveryRiders
(
    --WIP
    did INTEGER NOT NULL,
    salary FLOAT,
    deliveryStatus VARCHAR(20),
    numDelivered INTEGER,
    PRIMARY KEY (did)
);

CREATE TABLE Promotions ( -- WIP
    pid INTEGER NOT NULL,
    startDate DATE,
    endDate DATE,
    description VARCHAR(50),
    discountAmt FLOAT,
    PRIMARY KEY (pid)
);