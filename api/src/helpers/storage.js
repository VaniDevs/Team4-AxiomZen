var Promise = require('bluebird');
var mkdirp = require('mkdirp');
var fs = require('fs');

var multer = require('multer');

var path = __dirname + '/../../storage';

exports.upload = multer({
  storage: multer.diskStorage({
    destination: function(req, file, cb) {
      cb(null, path + '/report_' + req.params.id);
    },
    filename: function(req, file, cb) {
      cb(null, file.fieldname + '-' + Date.now() + '.jpeg');
    }
  })
});

exports.userUpload = multer({
  storage: multer.diskStorage({
    destination: function(req, file, cb) {
      cb(null, path + '/user_' + req.user.id);
    },
    filename: function(req, file, cb) {
      cb(null, file.fieldname + '-' + Date.now() + '.jpeg');
    }
  })
});

exports.createReportDirectory = function(id) {
  return new Promise(function(cb) {
    mkdirp(path + '/report_' + id, function(err) {
      if (err) console.log(err);

      cb(!err);
    });
  });
};

exports.createUserDirectory = function(id) {
  return new Promise(function(cb) {
    mkdirp(path + '/user_' + id, function(err) {
      if (err) console.log(err);

      cb(!err);
    });
  });
};