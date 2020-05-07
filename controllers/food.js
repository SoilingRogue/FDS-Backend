const getFoodData = (req, res, db) => {
    db.query(
        `select getFoodData()`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ error: `${error}` })
                return
            }
            res.status(200).json(results.rows[0]['getfooddata'])
        })
}

const getRestaurants = (req, res, db) => {
    db.query(
        `select getRestaurants()`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ error: `DB error: ${error}` })
                return
            }
            res.status(200).json(results.rows[0]['getrestaurants'])
        })
}

module.exports = {
    getFoodData,
    getRestaurants,
}
