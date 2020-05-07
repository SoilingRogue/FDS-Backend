const getFoodData = (req, res, db) => {
    db.query(
        `select getFoodData()`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            res.status(200).json(results.rows[0]['getfooddata'])
        })
}

module.exports = {
    getFoodData,
}
