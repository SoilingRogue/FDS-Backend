const getRiderMonthlyStats = (req, res, db) => {
    const { month } = req.body
    db.query(
        `select getRiderMonthlyStats(${month})`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `${error}` })
            }
            else {
                res.status(200).json(results.rows.map(x => x['getridermonthlystats'])[0])
            }
    })
}
const getDeliveryLocationStats = (req, res, db) => {
    db.query(
        `select getDeliveryLocationStats()`,
        (error, results) => {
            if (error) {
                res.status(400).json({ error: `${error}` })
            }
            else {
                res.status(200).json(results.rows[0]['getdeliverylocationstats'])
            }
    })
}

module.exports = {
    getRiderMonthlyStats,
    getDeliveryLocationStats
}
