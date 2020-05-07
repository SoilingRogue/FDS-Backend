------------------------- Promotion Functionalities -----------------------------
/*
* Functions:
* getFoodData(): Get promotions the order can receive
* getRestaurants(): Apply actual promotion
*/

DROP FUNCTION IF EXISTS getValidPromotions;
CREATE FUNCTION getValidPromotions(inputUid INTEGER, newFoodCost FLOAT, newDeliveryCost FLOAT,
    newTotalCost FLOAT, restId INTEGER)
RETURNS setof INTEGER
AS $$
DECLARE
    time varchar(8);
BEGIN
    SELECT convert(varchar(8), NOW(), 120) INTO time;
    SELECT rid FROM 
    RETURN QUERY 
    SELECT DISTINCT pid
    FROM FirstOrderPromotions, (SELECT * FROM Places WHERE uid = inputUid) AS F
    WHERE inputUid <> uid
    UNION
    SELECT DISTINCT pid
    FROM DeliveryPromotions D
    WHERE newDeliveryCost >= baseAmount
    AND time >= convert(varchar(8), D.startDate, 120)
    AND time <= convert(varchar(8), D.endDate, 120)
    UNION
    SELECT DISTINCT pid
    FROM FirstOrderPromotions natural join HasPromotions natural join RestaurantPromotions
    WHERE restId = rid AND basePrice <= newFoodCost
    AND time >= convert(varchar(8), startDate, 120)
    AND time <= convert(varchar(8), endDate, 120);
END;
$$ LANGUAGE 'plpgsql';


DROP FUNCTION IF EXISTS applyPromotion;
CREATE FUNCTION applyPromotion(promoUid INTEGER, newFoodCost FLOAT, newDeliveryCost FLOAT, 
    newTotalCost FLOAT)
RETURNS setof INTEGER
AS $$
BEGIN
    RETURN QUERY SELECT ;
END;
$$ LANGUAGE 'plpgsql';