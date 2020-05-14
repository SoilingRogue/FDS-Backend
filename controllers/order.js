const checkValidOrder = (req, res, db) => {
    const { uid, currentOrder } = req.body
    const totalCost = currentOrder.reduce((total, foodItem) => total + (foodItem.qty * foodItem.price), 0).toFixed(2)
    if (currentOrder.filter(x => x.rid !== currentOrder[0].rid).length > 0)
        res.status(400).json({ error: 'Cannot order from multiple restaurants' })
    else {
        db.query(
            `select getRestaurantMinCost(${currentOrder[0].rid})`,
            (error, results) => {
                if (error) {
                    res.status(400).json({ error: `DB error: ${error}` })
                }
                else if (results.rows[0]['getrestaurantmincost'] > totalCost) {
                    res.status(400).json({ error: 'Does not meet minimum order cost'})
                }
                else {
                    db.query(
                        `select getValidPromotions(${uid}, ${totalCost}, ${currentOrder[0].rid})`,
                        (error, results) => {
                            if (error) {
                                res.status(400).json({ error: `DB error: ${error}` })
                            }
                            else {
                                res.status(200).json(results.rows.map(x => x['getvalidpromotions']))
                            }
                        }
                    )
                }
            })
    }
}

const hasOngoingOrder = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select hasOngoingOrder(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).json(results.rows[0]['hasongoingorder'])
            }
    })
}

const addReviewAndRating = (req, res, db) => {
    const { uid, oid, rating, review } = req.body
    db.query(
        `select addReviewAndRating(${uid}, ${oid}, ${rating}, '${review}')`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `${error}` })
            }
            else {
                res.status(200).end()
            }
    })
}

const getRestaurantReviewsAndRatings = (req, res, db) => {
    const { rid } = req.body
    db.query(
        `select getRestaurantReviewsAndRatings(${rid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `${error}` })
            }
            else {
                res.status(200).json(results.rows[0]['getrestaurantreviewsandratings'])
            }
    })
}

const getPastOrders = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select getPastOrders(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).json(results.rows[0]['getpastorders'])
            }
    })
}

const getRecentOrderLocations = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select getRecentOrderLocations(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).json(results.rows.map(x => x['getrecentorderlocations']))
            }
    })
}

const placeOrder = async (req, res, db) => {
    const { uid, currentOrder, useRewardPoints, deliveryLocation } = req.body
    const foodCost = currentOrder.reduce((total, foodItem) => total + (foodItem.qty * foodItem.price), 0).toFixed(2)
    const serialisedOrder = currentOrder.map(x => `(${x.rid}, '${x.foodname}', ${x.qty})::FoodItemQty`).join(", ");
    // Might need to discount totalcost from promotions 
    let rewardPoints
    if (useRewardPoints) {
        try {
            let queryRes = await db.query(`select getCustomerRewardPoints(${uid});`)
            rewardPoints = Math.min(Math.floor((0.20 * foodCost) / 0.10), queryRes.rows[0]['getcustomerrewardpoints'])
        } catch(e) {
            res.status(400).json({ error: e })
        }
    } else {
        rewardPoints = 0
    }
    db.query(
        `CALL placeOrder(${uid}, ARRAY[${serialisedOrder}], ${foodCost}::FLOAT, ${(0.2 * foodCost).toFixed(2)}::FLOAT, ${(1.2 * foodCost).toFixed(2)}::FLOAT, ${rewardPoints}::INTEGER, '${deliveryLocation}'::TEXT);`,
        (error, results) => {
            if (error) {
                console.log("ERROR:" + error)
                res.status(400).json({ error: `${error}`.substring(7) })
            }
            else
                res.status(200).end()
        }
    )
}

const setTDepartToRest = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select setTDepartToRest(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).end()
            }
    })
}

const setTArriveAtRest = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select setTArriveAtRest(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).end()
            }
    })
}
const setTDepartFromRest = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select setTDepartFromRest(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).end()
            }
    })
}
const setTDeliverOrder = (req, res, db) => {
    const { uid } = req.body
    db.query(
        `select setTDeliverOrder(${uid})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `DB error: ${error}` })
            }
            else {
                res.status(200).end()
            }
    })
}

module.exports = {
    checkValidOrder,
    placeOrder,
    getRecentOrderLocations,
    hasOngoingOrder,
    setTDepartToRest,
    setTArriveAtRest,
    setTDepartFromRest,
    setTDeliverOrder,
    getPastOrders,
    addReviewAndRating,
    getRestaurantReviewsAndRatings
}
