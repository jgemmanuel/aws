var express = require('express');
var app = express();
var port = process.env.PORT || 8080;

// New call to compress content
app.use(express.compress());

app.use(express.static(__dirname + '/public'));

console.log("Listening on port " + port + ".")
app.listen(port);
