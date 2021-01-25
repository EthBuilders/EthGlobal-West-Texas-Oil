const express       = require('express');
const app           = express();
const path          = require('path');
const mysql         = require('mysql');
const session       = require('express-session');
const MySQLStore    = require('express-mysql-session')(session);
const Router        = require('./Router');

app.use(express.static(path.join(__dirname, 'build'))); // start 
app.use(express.json());

//console.log('testing server')

///DATABASE

const db = mysql.createConnection({
    host: 'localhost',  ///local server
    user: 'root',
    password: '',
    databse: 'myapp'  /// DB we made 

});

db.connect(function(err) {
    if (err){
    console.log('db error')
    throw err;
    return false;
    }
});

const sessionStore = new MySQLStore({
    expiration: (1825 * 86400 * 1000), // 5 years 
    endConnectionOnClose: false
}, db);


app.use(session({
    key: 'hfa8948hf4wh8ha8o4h',
    secret: 'frogs',
    store: sessionStore,
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: (1825 * 86400 * 1000),
        httpOnly: false
    }
}));

new Router(app, db); // dependence injection class based router for scaling 

app.get('/', function(req, res) {
    res.sendFile(path.join(__dirname, 'build', 'index.html'));

});

app.listen(3000);