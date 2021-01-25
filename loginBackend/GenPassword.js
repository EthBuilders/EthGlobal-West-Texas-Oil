const bcrypt = require('bcrypt');

let pswrd = bcrypt.hashSync('12345', 9);
console.log(pswrd);