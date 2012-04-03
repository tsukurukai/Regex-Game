// express
var express = require('express');
var app = express.createServer();

// テンプレートエンジンejsの設定
var ejs = require('ejs');
app.set('view engine', 'ejs');
app.set('view options', { layout: false });
app.set('views', __dirname + '/views');

// 設定
app.configure(function(){
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(express.session({secret: 'regex'}));
    app.use(express.static(__dirname + '/public')); // 静的ファイルの場所
});

// インクルード
var login = require('./modules/login');

// ルーティング
app.get('/', function(req, res) {
    res.render('index.ejs', {locals:{msg:'Hello Kinoko!'}});
});
app.get('/login', login.login);

// サーバー起動
var port = process.env.PORT || 8000;
app.listen(port, function(){
    console.log("WebApp start! Listening on " + port);
});

