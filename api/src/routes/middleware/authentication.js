var jwt = require('../../helpers/jwt');

module.exports = function(req, res, next) {
  var authToken = req.headers['x-authentication-token'];
  var decoded;
  console.log(jwt.verify(authToken));

  if (!authToken || !(decoded = jwt.verify(authToken))) return res.status(401).json({
    msg : 'Your not authorized buddy.'
  });

  req.models.user.get(decoded.id || decoded.userId, function(err, user) {
    if (err) return res.status(401).end();

    req.user = user;

    next();
  });
};