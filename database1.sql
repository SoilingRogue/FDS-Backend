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

-- restaurants init
INSERT INTO Restaurants (rid, rName, minDeliveryCost) VALUES
(0, "MACDONALDS", 9.99),
(1, "KFC", 0.01),
(2, "DTF", 20);

-- food categories init
INSERT INTO FoodCategories (categories) VALUES
("FastFood"),
("Chinese"),
("Western"),
("ChInEsE"); -- check if case sensitive

-- food items - whats the diff btw avail, dailystock & currentstock? + how to enforce dailystock >= currentstock + valid values for all
INSERT INTO FoodItems (foodName, availability, dailyStock, currentStock, price) VALUES
("CheeseBurger", 1, 0, 0, 3.99),
("ZingberBox", 1, 100, 100, 8.99),
("Dumplings", 0, 10000000000, 1000000000, 3), -- daily stock > 32 bit signed int
("Baozi", 1, 1, 1, 1);

-- food categories relation init - how to enforce food in at least 1 category?
INSERT INTO BelongsTo (foodName, categories) VALUES
("CheeseBurger", "FastFood"),
("CheeseBurger", "Western"), -- food in multiple categories
("ZingberBox", "FastFood"),
("Dumplings", "Chinese"),
("Baozi", "ChInEsE");

-- food rest init - how to enforce food belong to single rest?
INSERT INTO Sells (rName, foodName) VALUES
("MACDONALDS", "CheeseBurger"),
("KFC", "ZingberBox"),
("DTF", "Dumplings"),
("DTF", "baozi");

-- not used since promotable is not fully completed
INSERT INTO Promotions (pid, startDate, endDate) VALUES
(0, 2020-03-24, 2020-03-27), -- ended
(1, 2019-02-29, 2020-05-24), -- invalid date for start
(2, 2020-05-24, 2021-05-24); -- havent started yet

-- No orders added since the data for tables should be created when order is made

-- Users
INSERT INTO Users (uId, email, password) VALUES
(0, "rider0@gmail.com", "qwerty"),
(1, "rider1@gmail.com", "qwerty"),
(2, "rider2@gmail.com", "qwerty"),
(3, "rider3@gmail.com", "qwerty"),
(4, "rider4@gmail.com", "qwerty"),
(5, "rider5@gmail.com", "qwerty"),
(6, "rider6@gmail.com", "qwerty"),
(7, "rider7@gmail.com", "qwerty"),
(8, "rider8@gmail.com", "qwerty"),
(9, "rider9@gmail.com", "qwerty"),
(10, "cust0@gmail.com", "qwerty"),
(11, "cust1@gmail.com", "qwerty"),
(12, "cust2@gmail.com", "qwerty"),
(13, "cust3@gmail.com", "qwerty"),
(14, "manager0@gmail.com", "qwerty"),
(15, "staff@gmail.com", "qwerty");

INSERT INTO Managers (uId) VALUES
(14);

INSERT INTO RestaurantStaff (uId) VALUES
(15);

INSERT INTO Customers (uId, rewardPoints, creditCard) VALUES
(10, 1000000, "fsfsfsfsffffffff"),
(11, 0, "fsfsfsfsffffffff"), -- same credit card number as prev customer - valid?
(12, 1, "fsfsfsfsfffffffs"),
(13, 0, "fsfsfsfsffffsfff");

-- init riders & respective schedules
INSERt INTO DeliveryRiders (uId, deliveryStatus, commision) VALUES
(0, 1, 1),
(1, 1, 0.01),
(2, 1, 9.99),
(3, 0, 0),
(4, 1, 0),
(5, 1, 0),
(6, 0, -3.99), -- test
(7, 1, 0),
(8, 1, -3.99), -- test
(9, 1, 99999990);

-- how to enforce delivery rider belong to either partime XOR fulltime
INSERT INTO PartTime (uId, weeklyBaseSalary) VALUES
(0, 1),
(1, 1.1),
(2, 0),
(3, 9999999),
(4, 3.3333333); -- float value smaller than the smallest currency decimal point

INSERT INTO FullTime (uId, monthlyBaseSalary) VALUES
(5, 0),
(6, 0),
(7, 3000),
(8, 5.99),
(9, 1);

INSERT INTO DAYS (day, name) VALUES
(1, "MONDAY"),
(2, "TUESDAY"),
(3, "WEDNESDAY"),
(4, "THURSDAY"),
(5, "FRIDAY"),
(6, "SATURDAY"),
(7, "SUNDAY");

-- can add more data for part time shifts, all full time shifts are added alr
INSERT INTO Shifts (sid, startTime, endTime) VALUES
-- below are data for wws shifts
(0, 10, 13),
(1, 16, 18),
(2, 19, 22),
(3, 17, 20),
-- below are data for mws shifts
(4, 10, 14), -- 4 & 5 are tgt
(5, 15, 19),
(6, 11, 15), -- 6 & 7 tgt
(7, 16, 20),
(8, 12, 16), -- 8 & 9 tgt
(9, 17, 21),
(10, 13, 17), -- 10 & 11 tgt
(11, 18, 22);

-- missing init for part time, all full time shifts added alr
INSERT INTO HasShifts (id, sid, day) VALUES
-- full time shifts
(0, 4, 1),
(1, 5, 1),
(2, 6, 1),
(3, 7, 1),
(4, 8, 1),
(5, 9, 1),
(6, 10, 1),
(7, 11, 1),
(8, 4, 2),
(9, 5, 2),
(10, 6, 2),
(11, 7, 2),
(12, 8, 2),
(13, 9, 2),
(14, 10, 2),
(15, 11, 2),
(16, 4, 3),
(17, 5, 3),
(18, 6, 3),
(19, 7, 3),
(20, 8, 3),
(21, 9, 3),
(22, 10, 3),
(23, 11, 3),
(24, 4, 4),
(25, 5, 4),
(26, 6, 4),
(27, 7, 4),
(28, 8, 4),
(29, 9, 4),
(30, 10, 4),
(31, 11, 4),
(32, 4, 5),
(33, 5, 5),
(34, 6, 5),
(35, 7, 5),
(36, 8, 5),
(37, 9, 5),
(38, 10, 5),
(39, 11, 5),
(40, 4, 6),
(41, 5, 6),
(42, 6, 6),
(43, 7, 6),
(44, 8, 6),
(45, 9, 6),
(46, 10, 6),
(47, 11, 6),
(48, 4, 7),
(49, 5, 7),
(50, 6, 7),
(51, 7, 7),
(52, 8, 7),
(53, 9, 7),
(54, 10, 7),
(55, 11, 7);

-- mnissing init for part time
INSERT INTO HasSchedule (uId, id) VALUES
-- for full time riders
-- rider 5 works mon- friday shift 1
-- rider 6 mon-friday shift 2
-- rider 7 mon-friday shfit 3
-- rider 8 mon-friday shift 4
-- rider 9 wed-sunday: wed shift 1, thurs shift 2, firday shift 3, sat shift 4, sunday shift 4
(5, 0),
(5, 1),
(5, 8),
(5, 9),
(5, 16),
(5, 17),
(5, 24),
(5, 25),
(5, 32),
(5, 33),
(6, 2),
(6, 3),
(6, 10),
(6, 11),
(6, 18),
(6, 19),
(6, 26),
(6, 27),
(6, 34),
(6, 35),
(7, 4),
(7, 5),
(7, 12),
(7, 13),
(7, 20),
(7, 21),
(7, 28),
(7, 29),
(7, 36),
(7, 37),
(8, 6),
(8, 7),
(8, 14),
(8, 15),
(8, 22),
(8, 23),
(8, 30),
(8, 31),
(8, 38),
(8, 39),
(9, 16),
(9, 17),
(9, 26),
(9, 27),
(9, 36),
(9, 37),
(9, 46),
(9, 47),
(9, 54),
(9, 55);