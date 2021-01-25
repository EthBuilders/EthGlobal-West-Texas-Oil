const bcrypt = require('bcrypt');


class Router{  /// see login form ~ line 50 for where this is called from the front end of this 
    
    constructor(app, db) {
        this.login(app, db);
        this.logout(app, db);
        this.isLoggedIn(app, db);

    }

    login(app, db) { /// method and route 
        app.post('/login', (req,res) => {
            let username = req.body.username;
            let password = req.body.password;
            console.log(username);
            username = username.toLowerCase();   // all chars to lower 

            if(username.length > 12 || password.length > 12){
                res.json({
                    success: false, 
                    msg: 'An error has occoured'
                })
                return;
            }

            let cols = [username];
            db.query('SELECT * FROM user WHERE username = ? LIMIT 1', cols, (err, data, fields) => {
                    if (err) {
                        res.json({
                            success: false,
                            msg: 'error... '
                        })
                        return;
                    }
                        //// we found a user with the username 
                    if (data && data.length === 1){ // if user exists 
                            bcrypt.compare(password, data[0].password, (bcryptErr, verified) => {

                                if (verified){
                                    req.session.userID = data[0].id; /// starts session 
                                    res.json({
                                        success: true,
                                        username: data[0].username
                                    })
                                    return;
                                } else {
                                    res.json({
                                        success: false,
                                        msg: 'invalid password' 
                                    })
                                }
                            }); // compare what was passed iin tyo db 
                    } else { // if user does not exist 
                            res.json({
                                success: false,
                                msg: 'User not found try again '
                            })
                    }
            });

        });
    }

    logout(app, db) {
        app.post('/logout', (req, res) => {
            if (req.session.userID) {
                req.session.destroy();
                res.json({ 
                    success: true
                })
                return true;
            } else {
                res.json({
                    success: false
                })

                return false;
            }
        })
    }

    isLoggedIn(app, db) {

        app.post('/logout', (req, res) => {
        if (req.session.userID) {  // if id is set
            let cols = [req.session.userID];
            db.query('SELECT * FROM user WHERE id = ? LIMIT 1', (err, data, fields) => {
                if(data && data.length ===1) {
                    res.json({
                        success: true,
                        username: data[0].username
                    })
                    return true;
                } else {
                    res.json({
                        success: false
                    })
                }
            });
        } else {
            res.json({
                success: false 
            })
        }

        });
    }

}

module.exports = Router;