var express = require('express'),
	app = express.createServer();

var	sinaOAuth = require('./lib/sinaOAuth');

var fs = require('fs');

app.use(express.logger({ format: ':method :url :status' }));
app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.session({ secret: 'bang590' }));
app.use(app.router);


app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
app.use('/client',express.static(__dirname + '/client',{ cache:false}));
app.error(function(err, req, res){
	console.log("500:" + err + " file:" + req.url)
	res.render('500');
});

function outputAccess(req)
{
	console.log(req.cookies.access_key);
	console.log(req.cookies.access_secret);
}

app.get('/', function(req, res){
	outputAccess(req);
	console.log(typeof req.cookies.access_key);
	
	if(req.cookies.access_key && req.cookies.access_key != 'undefined')
	{
		res.redirect('/client/index.html');
	}
	else
	{
		res.sendfile('client/oauth.html');
	}
});

app.get('/gotooauth', function(req,res){
	var sinaoauth = new sinaOAuth();
	sinaoauth.oAuth(req, res, function(error, access_key, access_secret) {
		res.cookie("access_key", access_key);
		res.cookie("access_secret", access_secret);
		console.log(access_key);
		console.log(access_secret);

		outputAccess(req);
		res.redirect('/timeline');
	});
});

app.post('/update',function(req,res){
	var sinaoauth = new sinaOAuth(req.cookies.access_key, req.cookies.access_secret);
	var args = {status:req.param('status')};
	
	sinaoauth.update(args,function(){res.end();});
});


app.get('/timeline', function(req, res) {
	outputAccess(req);
	
	var sinaoauth = new sinaOAuth(req.cookies.access_key, req.cookies.access_secret);
	sinaoauth.friends_timeline({}, function(err, data) {
		if (err) return console.log(err);
		res.contentType('application/json');
		res.end(JSON.stringify(data));
	});
});

app.get('/friends',function(req,res){
	var sinaoauth = new sinaOAuth(req.cookies.access_key, req.cookies.access_secret);
	sinaoauth.friends({}, function(err, data) {
		if (err) return console.log(err);
		res.contentType('application/json');
		res.end(JSON.stringify(data));
	});
});


var port = process.env.PORT || 8000;
console.log("service run on " + port);

app.listen(port);