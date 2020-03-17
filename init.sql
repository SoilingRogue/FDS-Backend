CREATE TABLE Food
(
    fid INTEGER,
    name VARCHAR(50),
    type VARCHAR(20),
    PRIMARY KEY (fid)
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
    fid INTEGER NOT NULL,
    PRIMARY KEY (rid, fid),
    FOREIGN KEY (rid) REFERENCES Restaurants,
    FOREIGN KEY (fid) REFERENCES Food
);

CREATE TABLE Customers
(
    cEmail INTEGER,
    reward INTEGER,
    creditCard INTEGER,
    --Credit card has to have certain length
    lastOrder INTEGER,
    PRIMARY KEY (cEmail),
    FOREIGN KEY (cEmail) REFERENCES Users,
    FOREIGN KEY (lastOrder) REFERENCES OrderArchive
);

CREATE TABLE Orders -- WIP
(
    oid INTEGER NOT NULL,
    PRIMARY KEY (oid, rid, cEmail, dEmail, orderDate)
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

CREATE TABLE Users
(
    email VARCHAR(50),
    password VARCHAR(50),
    PRIMARY KEY (email)
);

CREATE TABLE RestaurantStaffs
(
    rEmail VARCHAR(50),
    PRIMARY KEY (rEmail),
    FOREIGN KEY (rEmail) REFERENCES Users
);

CREATE TABLE Managers
(
    mEmail VARCHAR(50),
    PRIMARY KEY (mEmail),
    FOREIGN KEY (Email) REFERENCES Users
);