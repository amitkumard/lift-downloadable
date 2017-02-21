/*jslint node:true*/
/*eslint no-unused-params:0*/
/* These lines are hints to the code editor */

/**
 * Load the appropriate modules for our web application
*/
var http = require('http');
var path = require('path');
var express = require('express');   // The ExpressJS framework
var morgan  = require('morgan');    // For clearing logging messages
var fs = require('fs');

/**
 * Setup the Express engine
**/
var app = express();
app.set('port', process.env.PORT || 3000);
app.set('view engine', 'ejs');

// Stuff to do for all routes
app.use(morgan('dev'));
app.use(express.static(path.join(__dirname, 'public')));

/**
 * This is our home route.  This gets called when we visit our
 * base address http://MYSERVERNAME.mybluemix.net/
**/

/* add var definition for your new variable, userbytwo here */

app.get('/', function(req, res){
	res.write('This is lift-downloadable app home page');
  res.end();
});

app.get('/bluemix-lift-slingshot-setup-mac.zip', function(req, res){
  var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-mac.zip';
  res.setHeader('content-type', 'binary');
  console.log(filenameWithPath);
  res.download(filenameWithPath);
});

app.get('/bluemix-lift-slingshot-setup-mac.zip.SHA-256', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-mac.zip.SHA-256';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);
	});


app.get('/bluemix-lift-slingshot-setup-win.exe.SHA-256', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-win.exe.SHA-256';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);
	});


app.get('/bluemix-lift-slingshot-setup-win.exe', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-win.exe';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);
});

app.get('/bluemix-lift-slingshot-setup-linux.bin', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-linux.bin';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);  
});


app.get('/bluemix-lift-slingshot-setup-linux.bin.SHA-256', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/bluemix-lift-slingshot-setup-linux.bin.SHA-256';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);  
	});

app.get('/Sample.txt', function(req, res){
	 var filenameWithPath = __dirname+'/uploaded_files/Sample.txt';
	  res.setHeader('content-type', 'binary');
	  console.log(filenameWithPath);
	  res.download(filenameWithPath);  
});


/** new URLS for two new files handling auto upgrade
 * 
 */
app.get('/manifest.json', function(req, res){
	  var filenameWithPath = __dirname+'/public/manifest.json';
	  fs.stat(filenameWithPath, function(err, stats) {
	      res.setHeader('content-type', 'binary');
	      res.setHeader('content-length', stats.size);
	      res.download(filenameWithPath);
	  });
	  console.log(filenameWithPath);
	 
	});
	app.get('/LiftJar-2.jar', function(req, res){
	    var filenameWithPath = __dirname+'/public/LiftJar-2.jar';
	    fs.stat(filenameWithPath, function(err, stats) {
	        res.setHeader('content-type', 'binary');
	        res.setHeader('content-length', stats.size);
	        res.download(filenameWithPath);
	    });
	    console.log(filenameWithPath);
	});
	
/**
 * This is where the server is created and run.  Everything previous to this
 * was configuration for this server.
**/
var server = http.createServer(app);
server.listen(app.get('port'), function(){
   console.log('Express server listening on port ' + app.get('port'));
});