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
    time text;
BEGIN
    SELECT convert(text, NOW(), 120) INTO time;
    RETURN QUERY 
    SELECT DISTINCT pid
    FROM FirstOrderPromotions, (SELECT * FROM Places WHERE uid = inputUid) AS F
    WHERE inputUid <> uid
    UNION
    SELECT DISTINCT pid
    FROM DeliveryPromotions D
    WHERE newDeliveryCost >= baseAmount
    AND time >= select convert(text, D.startDate, 120)
    AND time <= select convert(text, D.endDate, 120)
    UNION
    SELECT DISTINCT pid
    FROM FirstOrderPromotions natural join HasPromotions natural join RestaurantPromotions
    WHERE restId = rid AND basePrice <= newFoodCost
    AND time >= select convert(text, startDate, 120)
    AND time <= select convert(text, endDate, 120);
END;
$$ LANGUAGE 'plpgsql';


DROP FUNCTION IF EXISTS applyPromotion;
CREATE FUNCTION applyPromotion(promoUid INTEGER, newFoodCost FLOAT, newDeliveryCost FLOAT, 
    newTotalCost FLOAT)
RETURNS INTEGER
AS $$
DECLARE
    finalFoodCost FLOAT;
    finalDeliveryCost FLOAT;
    finalTotalCost FLOAT;
BEGIN
    IF (SELECT count(*) FROM FirstOrderPromotions WHERE pid = promoUid) > 0 THEN
        SELECT newTotalCost * (1 - F.discountPercentage) INTO finalTotalCost FROM FirstOrderPromotions F WHERE pid = promoUid;
        SELECT 0.0 into finalFoodCost;
        SELECT 0.0 into finalDeliveryCost;
    ELSE
        IF (SELECT count(*) FROM DeliveryPromotions WHERE pid = promoUid) > 0 THEN
            SELECT newDeliveryCost * D.discountPercentage INTO finalDeliveryCost FROM DeliveryPromotions D WHERE pid = promoUid;
            SELECT 0.0 into finalFoodCost;
            SELECT newTotalCost - finalDeliveryCost into finalTotalCost;
            SELECT 0.0 into finalDeliveryCost;
        ELSE
            SELECT newFoodCost * discountPercentage INTO finalFoodCost FROM PriceTimeOrderPromotions WHERE pid = promoUid;
            SELECT newTotalCost - finalFoodCost into finalTotalCost;
            SELECT 0.0 into finalFoodCost;
            SELECT 0.0 into finalDeliveryCost;
        END IF;
    END IF;
    RETURN finalFoodCost + finalDeliveryCost + finalTotalCost;
END;
$$ LANGUAGE 'plpgsql';