const userTypeToEmailColMap = new Map()
userTypeToEmailColMap.set('managers', 'memail')
userTypeToEmailColMap.set('restaurantstaff', 'remail')
userTypeToEmailColMap.set('deliveryriders', 'demail')
userTypeToEmailColMap.set('customers', 'cemail')

const addUser = (req, res, db) => {
    const { email, userType, password } = req.body
    db.query(
        `with ins as (
            insert into Users(email, password) 
            values ('${email}', '${password}')
            returning uId
        )
        insert into ${userType}
        select ins.uId from ins
        returning uId`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            console.log(results.rows[0])
            res.status(200).json()
        })
}

const validateEmail = (req, res, db) => {
    console.log(req)
    const { email, userType } = req.body
    db.query(
        `SELECT count(*) FROM Users WHERE email = '${email}'
            and Users.email in (SELECT ${userTypeToEmailColMap.get(userType)} from ${userType})`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            if (results.rows[0]['count'] === '1')
                res.status(200).json()
            else
                res.status(400).json({ dbError: 'User Not Found' })
        })
}

const validatePassword = (req, res, db) => {
    const { email, userType, password } = req.body
    db.query(
        `SELECT count(*) FROM Users WHERE email = '${email}' AND password = '${password}'
            and Users.email in (SELECT ${userTypeToEmailColMap.get(userType)} from ${userType})`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            if (results.rows[0] && results.rows[0]['count'] === '1')
                res.status(200).json()
            else
                res.status(400).json({ dbError: `Validation failed` })
        })
}

module.exports = {
    addUser,
    validateEmail,
    validatePassword,
}
