const getFoodData = (req, res, db) => {
    db.query(
        `select foodName, rName, price from Sells S1 join FoodItems F1 using (foodName)`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            res.status(200).json(results.rows)
        })
}

module.exports = {
    getFoodData,
}
