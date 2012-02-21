exports.disp = function(req, res) {
    res.render('login.ejs', {locals:{msg:'ログイン画面'}});
};
