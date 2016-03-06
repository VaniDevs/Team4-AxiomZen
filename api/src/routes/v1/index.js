var authentication = require('../middleware/authentication');
var express = require('express');

module.exports = function() {
  var router = express.Router();

  var users = require('./users');

  router.get('/user', authentication, users.get);
  router.get('/user/:id', authentication, users.get);

  router.put('/user', authentication, users.update);
  router.put('/avatar', authentication, users.avatar);

  router.post('/authenticate', users.authenticate);

  var reports = require('./reports');

  router.get('/reports', authentication, reports.get);
  router.get('/reports/:id', authentication, reports.get);

  router.post('/report', authentication, reports.add);

  router.put('/report/:id', authentication, reports.update);

  router.put('/false_alarm', authentication, reports.cancelPreviousReport);

  return router;
};