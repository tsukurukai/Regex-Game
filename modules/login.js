exports.disp = function(req, res) {
    res.render('login.ejs', {locals:{msg:'ログイン画面'}});
};


// OAuth認証情報
var DOMAIN = 'localhost';
var PORT = '8000';
var consumerkey = 'key';
var consumerSecret = 'secret';
var oauth_mod = require('oauth').OAuth;
var oauth = new oauth_mod(
    'https://api.twitter.com/oauth/request_token',
    'https://api.twitter.com/oauth/access_token',
    consumerkey,
    consumerSecret,
    '1.0',
    'http://' + DOMAIN + ':' + PORT + '/login',
    'HMAC-SHA1'
);

exports.login = function(req, res) {
    var oauth_token = req.query.oauth_token;
    var oauth_verifier = req.query.oauth_verifier;
    console.log('認証後のリクエストトークンを使ってアクセストークンをTwitterからもらう');
    if (oauth_token && oauth_verifier && req.session.oauth) {
        oauth.getOAuthAccessToken(oauth_token, null, oauth_verifier,
            function(error, access_token, access_token_secret, result) {
                if (error) {}
                else {
                    console.log('アクセストークンが取得できたので、ログイン成功');
                    req.session.regenerate(function(){
                        req.session.user = result.screen_name;
                        res.redirect('/');
                    });
                }
            });
    } else {
        console.log('コンシューマーキーを使ってTwitterからリクエストトークンを受け取る');
        oauth.getOAuthRequestToken(function(error, request_token, request_token_secret, results) {
            if (error) {console.log(error)}
            else {
                req.session.oauth = {
                    oauth_token: request_token,
                    oauth_token_secret: request_token_secret,
                    request_token_results: results
                };
                console.log('認証処理を行うためTwitterへリダイレクト');
                res.redirect('https://api.twitter.com/oauth/authorize?oauth_token=' + request_token);
            }
        });
    }
};

