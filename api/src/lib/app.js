var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var express = require('express');
var config = require('./config');
var logger = require('morgan');

var app = express();

var orm = require('orm');
var ormTimestamps = require('orm-timestamps');
var ormTransaction = require('orm-transaction');
var ormPaging = require('orm-paging');

// Add headers
app.use(function (req, res, next) {

  // Website you wish to allow to connect
  res.setHeader('Access-Control-Allow-Origin', '*');

  // Request methods you wish to allow
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

  // Request headers you wish to allow
  res.setHeader('Access-Control-Allow-Headers', 'x-authentication-token,x-api-token,content-type');

  // Set to true if you need the website to include cookies in the requests sent
  // to the API (e.g. in case you use sessions)
  res.setHeader('Access-Control-Allow-Credentials', true);

  // Pass to next layer of middleware
  next();
});

app.use(orm.express(config.db.connectionString(), {
  define : function(db, models) {

    db.use(ormPaging);
    db.use(ormTimestamps);
    db.use(ormTransaction);

    require('../models').config(db, models);

    app.db = db;
    app.models = models;

    db.sync(function() {

    });
  }
}));

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

require('../routes')(app);

module.exports = app;
