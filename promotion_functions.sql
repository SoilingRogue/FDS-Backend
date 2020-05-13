------------------------- Promotion Functionalities -----------------------------
/*
* Functions:
* getValidPromotions(): Get promotions the order can receive
* applyPromotion(): Apply actual promotion
*/

DROP FUNCTION IF EXISTS getValidPromotions;
CREATE FUNCTION getValidPromotions(inputUid INTEGER, newFoodCost FLOAT, restId INTEGER)
RETURNS setof INTEGER
AS $$
DECLARE
    time TIMESTAMP;
BEGIN
    SELECT NOW() INTO time;
    RETURN QUERY 
    SELECT DISTINCT pid
    FROM FirstOrderPromotions left join (SELECT * FROM Places WHERE uid = inputUid) AS F on 1 = 1
    WHERE inputUid <> uid OR uid IS NULL
    UNION
    SELECT DISTINCT pid
    FROM DeliveryPromotions D
    WHERE 0.20 * newFoodCost >= baseAmount
    AND time >= D.startDate
    AND time <= D.endDate
    UNION
    SELECT DISTINCT pid
    FROM PriceTimeOrderPromotions natural join HasPromotions natural join RestaurantPromotions
    WHERE restId = rid AND basePrice <= newFoodCost
    AND time >= startDate
    AND time <= endDate;
END;
$$ LANGUAGE 'plpgsql';


DROP FUNCTION IF EXISTS applyPromotion;
CREATE FUNCTION applyPromotion(promoUid INTEGER, newFoodCost FLOAT, newDeliveryCost FLOAT, 
    newTotalCost FLOAT)
RETURNS FLOAT
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