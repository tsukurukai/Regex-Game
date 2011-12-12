var express = require('express');

var app = express.createServer();

app.get('/', function(req, res) {
    res.send('Hello Kinoko!');
});

var port = process.env.PORT || 8000;
app.listen(port, function(){
    console.log("WebApp start! Listening on " + port);
});

