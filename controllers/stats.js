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

const getMonthlyOrder = (req, res, db) => {
  const month = req.body();
  db.query(`select getTotalMonthlyOrder(${month})`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res.status(200).json(results.rows[0]["gettotalmonthlyorder"][0]["count"]);
  });
};

const getMonthlyCost = (req, res, db) => {
  const month = req.body();
  db.query(`select getTotalMonthlyCost($(month))`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res.status(200).json(results.rows[0]["gettotalmonthlycost"][0]["sum"]);
  });
};

const getMonthlyCustomers = (req, res, db) => {
  const month = req.body();
  db.query(`select getTotalMonthlyNewCustomer($(month))`, (error, results) => {
    if (error) {
      console.log(error);
      res.status(400).json({ error: `${error}` });
      return;
    }
    res
      .status(200)
      .json(results.rows[0]["gettotalmonthlynewcustomer"][0]["count"]);
  });
};

const getRiderMonthlyStats = (req, res, db) => {
  db.query(`select getRiderMonthlyStats(4)`,
    (error, results) => {
      if (error) {
        console.log(error);
        res.status(400).json({ error: `${error}` });
      }
      res.status(200).json(results.rows[0]["getridermonthlystats"]);
    });
};

module.exports = {
  getTotalOrder,
  getTotalCost,
  getTotalCustomers,
  getMonthlyOrder,
  getMonthlyCost,
  getMonthlyCustomers,
  getRiderMonthlyStats,
};
