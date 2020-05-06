const express = require('express')

require('dotenv').config()

// Express Middleware
const helmet = require('helmet') // creates headers that protect from attacks (security)
const bodyParser = require('body-parser') // turns response into usable format
const cors = require('cors')  // allows/disallows cross-site communication
const morgan = require('morgan') // logs requests

// const { Pool } = require('pg')
// const db = new Pool({
//     connectionString: process.env.DATABASE_URL,
//     ssl: true
//   });

// db Connection w/ localhost
const { Pool } = require('pg')
const db = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'fdsdb',
    password: 'password',
    port: 5432,
})

// Controllers - aka, the db queries
const main = require('./controllers/main')
const order = require('./controllers/order')
const food = require('./controllers/food')

// App
const app = express()

// App Middleware
const whitelist = ['http://localhost:3001', 'http://fooddeliveries.herokuapp.com/']
const corsOptions = {
    origin: function (origin, callback) {
        if (whitelist.indexOf(origin) !== -1 || !origin) {
            callback(null, true)
        } else {
            callback(new Error('Not allowed by CORS'))
        }
    }
}
app.use(helmet())
app.use(cors(corsOptions))
app.use(bodyParser.json())
app.use(morgan('combined')) // use 'tiny' or 'combined'

// auth routes
app.post('/add_customer', (req, res) => main.addCustomer(req, res, db))
app.post('/add_delivery_rider', (req, res) => main.addDeliveryRider(req, res, db))
app.post('/add_restaurant_staff', (req, res) => main.addRestaurantStaff(req, res, db))
app.post('/add_fds_manager', (req, res) => main.addFdsManager(req, res, db))

app.post('/validate_email', (req, res) => main.validateEmail(req, res, db))
app.post('/validate_password', (req, res) => main.validatePassword(req, res, db))
app.post('/change_password', (req, res) => main.changePassword(req, res, db))
app.post('/change_credit_card', (req, res) => main.changeCreditCard(req, res, db))
app.post('/delete_user', (req, res) => main.deleteUser(req, res, db))

app.post('/check_valid_order', (req, res) => order.checkValidOrder(req, res, db))

app.get('/get_food_data', (req, res) => food.getFoodData(req, res, db))


// App Server Connection
app.listen(process.env.PORT || 3000, () => {
    console.log(`app is running on port ${process.env.PORT || 3000}`)
})
