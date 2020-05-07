-- Add data for restaurant and food
insert into Restaurants(rName, minOrderCost) values('tian tian', 7);
insert into Restaurants(rName, minOrderCost) values('a1 bakkutteh place', 20);
insert into Restaurants(rName, minOrderCost) values('koi', 5);
insert into Restaurants(rName, minOrderCost) values('ameens', 15);
insert into Restaurants(rName, minOrderCost) values('prata house', 10);
insert into Restaurants(rName, minOrderCost) values('makcik shop', 5);
insert into Restaurants(rName, minOrderCost) values('astons', 8);

insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(1, 'chicken rice', 1, 100, 2, 4.5);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(7, 'steak', 1, 100, 55, 10.0);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(3, 'bubble tea', 0, 100, 0, 2.5);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(2, 'bak kut teh', 1, 40, 40, 3.5);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(5, 'prata', 1, 40, 20, 1.5);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(6, 'nasi lemak', 0, 40, 0, 3.5);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(4, 'nasi padang', 0, 50, 0, 3.8);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(4, 'nasi goreng', 1, 40, 40, 4.2);
insert into FoodItems(rid, foodName, availability, dailyLimit, currentOrders, price) values(5, 'murtabak', 1, 30, 30, 3.6);

insert into FoodCategories values('chinese');
insert into FoodCategories values('western');
insert into FoodCategories values('indian');
insert into FoodCategories values('malay');
insert into FoodCategories values('drinks');

insert into BelongsTo values(1, 'chicken rice', 'chinese');
insert into BelongsTo values(7, 'steak', 'western');
insert into BelongsTo values(3, 'bubble tea', 'drinks');
insert into BelongsTo values(2, 'bak kut teh', 'chinese');
insert into BelongsTo values(5, 'prata', 'indian');
insert into BelongsTo values(6, 'nasi lemak', 'malay');
insert into BelongsTo values(4, 'nasi padang', 'malay');
insert into BelongsTo values(4, 'nasi goreng', 'malay');
insert into BelongsTo values(5, 'murtabak', 'indian');


-- Promotions
insert into Promotions values(1);
insert into Promotions values(2);
insert into Promotions values(3);
insert into Promotions values(4);

insert into FDSPromotions values(1);
insert into FDSPromotions values(2);

insert into FirstOrderPromotions values(1, 0.5);

insert into DeliveryPromotions values(2, '2020-05-01', '2021-05-01', 1.0, 0.0);

insert into RestaurantPromotions values(3, '2020-05-01', '2020-06-01');
insert into RestaurantPromotions values(4, '2020-05-01', '2020-06-01');

insert into PriceTimeOrderPromotions values(3, 0.1, 20.0);
insert into PriceTimeOrderPromotions values(3, 0.2, 40.0);

insert into HasPromotions values(1, 3);
insert into HasPromotions values(2, 4);


-- insert into Orders (foodCost, deliveryCost, totalCost, pointsUsed, deliveryLocation) values (10, 1, 10.8, 2, 'angmokio blk 888');
-- insert into ConsistsOf (oid, foodName, rid, quantity) values (1, 'chicken rice', 1, 1);

-- insert into Orders (foodCost, deliveryCost, totalCost, pointsUsed, deliveryLocation) values (15, 2.5, 17.3, 2, 'angmokio blk 288');
-- insert into ConsistsOf (oid, foodName, rid, quantity) values (3, 'bak kut teh', 2, 1);

-- insert into Orders (foodCost, deliveryCost, totalCost, pointsUsed, deliveryLocation) values (11, 1, 11.8, 2, 'angmokio blk 588');
-- insert into ConsistsOf (oid, foodName, rid, quantity) values (4, 'nasi lemak', 6, 1);

-- insert into Orders (foodCost, deliveryCost, totalCost, pointsUsed, deliveryLocation) values (14, 2, 15.8, 2, 'angmokio blk 188');
-- insert into ConsistsOf (oid, foodName, rid, quantity) values (5, 'nasi padang', 4, 1);

-- insert into Orders (foodCost, deliveryCost, totalCost, pointsUsed, deliveryLocation) values (8, 0.5, 8.3, 2, 'angmokio blk 88');
-- insert into ConsistsOf (oid, foodName, rid, quantity) values (6, 'bubble tea', 3, 1);

-- Rough order flow -- 

-- Create users
select null from addCustomer('cust1@gmail.com', 'password'); -- uid 1
select null from addCustomer('cust2@gmail.com', 'password'); -- uid 2
select null from addCustomer('cust3@gmail.com', 'password'); -- uid 3
select null from addDeliveryRider('rider1@gmail.com', 'password'); -- uid 4
select null from addDeliveryRider('rider2@gmail.com', 'password'); -- uid 5
select null from addDeliveryRider('rider3@gmail.com', 'password'); -- uid 6
select null from addDeliveryRider('rider4@gmail.com', 'password'); -- uid 7
select null from addRestaurantStaff('staff1@gmail.com', 'password', 1); -- uid 8
select null from addRestaurantStaff('staff2@gmail.com', 'password', 2); -- uid 9
select null from addRestaurantStaff('staff3@gmail.com', 'password', 3); -- uid 10
select null from addRestaurantStaff('staff4@gmail.com', 'password', 4); -- uid 11
select null from addFdsManager('manager1@gmail.com', 'password'); -- uid 12
select null from addFdsManager('manager2@gmail.com', 'password'); -- uid 13
select null from addFdsManager('manager3@gmail.com', 'password'); -- uid 14
select null from addFdsManager('manager4@gmail.com', 'password'); -- uid 15

-- not used since promotable is not fully completed
-- INSERT INTO Promotions (pid, startDate, endDate) VALUES
-- (0, 2020-03-24, 2020-03-27), -- ended
-- (1, 2019-02-29, 2020-05-24), -- invalid date for start
-- (2, 2020-05-24, 2021-05-24); -- havent started yet

-- No orders added since the data for tables should be created when order is made

-- how to enforce delivery rider belong to either partime XOR fulltime
INSERT INTO PartTimers (uid) VALUES
(4),
(5);

INSERT INTO WWS(uid, week) VALUES
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(5, 1),
(5, 2),
(5, 3),
(5, 4);

INSERT INTO PTShift (week, day, startTime, endTime, uid) VALUES
(1, 1, 10, 14, 4), -- First PT Worker
(1, 2, 15, 19, 4),
(1, 4, 16, 20, 4),
(1, 3, 12, 16, 4),
(2, 1, 10, 14, 4),
(2, 2, 15, 19, 4),
(2, 4, 16, 20, 4),
(2, 3, 12, 16, 4),
(3, 1, 10, 14, 4),
(3, 2, 15, 19, 4),
(3, 4, 16, 20, 4),
(3, 3, 12, 16, 4),
(4, 1, 10, 14, 4),
(4, 2, 15, 19, 4),
(4, 4, 16, 20, 4),
(4, 3, 12, 16, 4),
(1, 4, 10, 14, 5), -- Second PT Worker
(1, 3, 15, 19, 5),
(1, 1, 16, 20, 5),
(1, 5, 12, 16, 5),
(2, 6, 10, 14, 5),
(2, 5, 15, 19, 5),
(2, 1, 16, 20, 5),
(2, 3, 12, 16, 5),
(3, 5, 10, 14, 5),
(3, 2, 15, 19, 5),
(3, 3, 16, 20, 5),
(3, 1, 12, 16, 5),
(4, 5, 10, 14, 5),
(4, 2, 15, 19, 5),
(4, 6, 16, 20, 5),
(4, 4, 12, 16, 5);

INSERT INTO FullTimers (uid) VALUES
(6),
(7);

INSERT INTO FTShift(sId, start1, end1, start2, end2) VALUES
(1, 10, 14, 15, 19),
(2, 11, 15, 16, 20),
(3, 12, 16, 17, 21),
(4, 13, 17, 18, 22);

INSERT INTO MWS(uid, month, sid, day) VALUES
(6, 5, 1, 1), -- First FullTimer for May, June
(6, 5, 3, 2),
(6, 5, 2, 3),
(6, 5, 4, 4),
(6, 5, 1, 5),
(6, 6, 4, 2),
(6, 6, 2, 3),
(6, 6, 1, 4),
(6, 6, 3, 5),
(6, 6, 4, 6),
(7, 5, 3, 1), -- Second FullTimer for May, June
(7, 5, 2, 2),
(7, 5, 4, 3),
(7, 5, 1, 4),
(7, 5, 2, 5),
(7, 6, 4, 2),
(7, 6, 2, 3),
(7, 6, 3, 4),
(7, 6, 4, 5),
(7, 6, 1, 6)
