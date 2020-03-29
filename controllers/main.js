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
            res.status(200).json({ uid: results.rows[0]['uid'], email })
        })
}

const validateEmail = (req, res, db) => {
    console.log(req)
    const { email, userType } = req.body
    db.query(
        `with temp as (
            select uid, email
            from Users U join ${userType} M using (uid)
        )
        select * from temp T where T.email = '${email}'`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            if (results.rowCount > 0)
                res.status(200).json(results.rows[0])
            else
                res.status(400).json({ dbError: 'User Not Found' })
        })
}

const validatePassword = (req, res, db) => {
    const { email, userType, password } = req.body
    db.query(
        `with temp as (
            select uid, email, password
            from Users U join ${userType} M using (uid)
        )
        select * from temp T where T.email = '${email}' AND T.password = '${password}'`,
        (error, results) => {
            if (error) {
                console.log(error)
                res.status(400).json({ dbError: `DB error: ${error}` })
                return
            }
            console.log(results)
            if (results.rowCount > 0)
                res.status(200).json(results.rows[0])
            else
                res.status(400).json({ dbError: `Validation failed` })
        })
}

module.exports = {
    addUser,
    validateEmail,
    validatePassword,
}
