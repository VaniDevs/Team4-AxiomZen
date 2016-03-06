var jwt = require('jsonwebtoken');
var fs = require('fs');

var privateKey = fs.readFileSync(__dirname+'/../files/eva.private.key');
var publicKey = fs.readFileSync(__dirname+'/../files/eva.public.pem');

exports.sign = function(user) {
  if (!user) return null;

  return jwt.sign({
    id : user.id
  }, privateKey, {
    algorithm: 'RS256',
    expiresIn: '365d'
  });
};

exports.verify = function(token) {
  if (!token) return null;
  return jwt.verify(token, publicKey, { algorithm: 'RS256' });
};

exports.token = function(data) {
  if (!data) return null;
  return jwt.sign(data||{}, privateKey, { algorithm: 'RS256' });
};