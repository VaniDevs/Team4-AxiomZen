var express = require('express');

var apiAccess = require('./middleware/apiAccess');
var config = require('../lib/config');
var fs = require('fs');


module.exports = function(app) {
  var router = express.Router();

  var twilio = require('./twilio');

  // Integration Possibility
  router.post('/twilio/message', twilio.handleMessage);

  // TODO:
  //router.options('/img/:report/:filename', require('cors')());
  router.get('/img/:report/:filename', require('cors')(), function(req, res) {
    res.set('Content-Type', 'image/jpeg');
    res.send(fs.readFileSync(__dirname+'/../../storage/'+req.params.report+'/'+req.params.filename));
  });

  app.use(apiAccess);

  config.versions.forEach(function(version) {
    app.use('/api/'+version, require('./'+version)());
  });

  app.use('/api', router);
};
