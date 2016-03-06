var Promise = require('bluebird');
var Twilio = require('twilio');

var config = require('../lib/config');
var client = new Twilio(config.twilio.accountSID, config.twilio.authToken);

exports.sendVerificationCode = function(number, code) {
  return this.sendMessage(number, 'Hi! Your verification code is '+code);
};

exports.sendMessage = function(number, message) {
  return new Promise(function(cb) {
    client.sendMessage({
      to : number,
      from : config.twilio.number,
      body : message
    }, function(err) {
      if (err) console.log(err);
      cb(!err);
    });
  });
};