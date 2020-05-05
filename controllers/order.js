const checkValidOrder = (req, res, db) => {
    const { currentOrder } = req.body
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
                else if (results.rows[0]['getrestaurantmincost'] < totalCost)
                    res.status(400).json({ error: 'Does not meet minimum order cost'})
                else
                    res.status(200).end()
            })
    }
}

module.exports = {
    checkValidOrder,
}
