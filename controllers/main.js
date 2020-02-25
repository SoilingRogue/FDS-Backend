const getData = (req, res, db) => {
  db.query('SELECT * FROM test', (error, results) => {
    if (error) {
      console.log(error);
    }
    res.status(200).json(results.rows)
  })
}

module.exports = {
  getData
}