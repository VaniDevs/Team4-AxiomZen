var config = require('../../lib/config');
var errors = require('../../helpers/errors');

module.exports = function(req, res, next) {
  // TODO: FIX !!!!!!!!!!!!!!
  if (req.method === 'OPTIONS') {
    console.log(req.headers);
    return next();
  }
  ///

  var apiToken = req.headers['x-api-token'];

  //console.log("REQUEST QUERY : ", req.query);
  //console.log("REQUEST BODY : ", req.body);

  if (!apiToken || apiToken !== config.apiToken) return res.status(401).json({
    msg : 'Bro! Invalid Api Token.'
  });

  next();
};