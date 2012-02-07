// express
var express = require('express');
var app = express.createServer();

// テンプレートエンジンejsの設定
var ejs = require('ejs');
app.set('view engine', 'ejs');
app.set('view options', { layout: false });
app.set('views', __dirname + '/views');

// Configuration
app.configure(function(){
  app.use(express.static(__dirname + '/public'));
});

app.get('/', function(req, res) {
    res.render('login.ejs', {locals:{msg:'Hello Kinoko!'}});
});

var port = process.env.PORT || 8000;
app.listen(port, function(){
    console.log("WebApp start! Listening on " + port);
});

