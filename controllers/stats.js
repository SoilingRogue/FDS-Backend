const getTotalOrder = (req, res, db) => {
  db.query(`select getTotalOrder()`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    console.log("res: " + results.rows[0]["gettotalorder"]["count"]);
    console.log("res2: " + results);
    res.status(200).json(results.rows[0]["gettotalorder"]["count"]);
  });
};

const getTotalCost = (req, res, db) => {
  db.query(`select getTotalCost()`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res.status(200).json(results.rows[0]["gettotalcost"]["sum"]);
  });
};

const getTotalCustomers = (req, res, db) => {
  db.query(`select getTotalCustomers()`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res.status(200).json(results.rows[0]["gettotalcustomers"][0]["count"]);
  });
};

const getMonthlyStats = (req, res, db) => {
  const { month } = req.body;
  db.query(`select getMonthlyStats(${month})`, (error, results) => {
    if (error) {
      console.log(error);
      //console.log("error occurred");
      res.status(400).json({ error: `${error}` });
      return;
    }
    //console.log("we good");
    res.status(200).json(results.rows[0]["getmonthlystats"][0]);
  });
};

const getThisMonthStats = (req, res, db) => {
  db.query(`select getMonthlyStats(5)`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res.status(200).json(results.rows[0]["getmonthlystats"][0]);
  });
};

const getRiderMonthlyStats = (req, res, db) => {
  db.query(`select getRiderMonthlyStats(4)`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
    }
    res.status(200).json(results.rows[0]["getridermonthlystats"]);
  });
};

const getRestaurantFoodData = (req, res, db) => {
  db.query(`select getRestaurantFoodData(8)`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
    }
    res.status(200).json(results);
  })
}


module.exports = {
  getTotalOrder,
  getTotalCost,
  getTotalCustomers,
  getMonthlyStats,
  getThisMonthStats,
  getRiderMonthlyStats,
  getRestaurantFoodData
};
