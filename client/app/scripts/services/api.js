'use strict';

/**
 * @ngdoc service
 * @name evaWebApp.api
 * @description
 * # api
 * Service in the evaWebApp.
 */

angular.module('evaWebApp').service('api', function ($http) {
  var host = '';
  function login(username, password) {
    console.log('hit login');
    var request = $http.post(host + '/login', {
      username: username,
      password: password
    }).then(validateToken,errorHandler);
    return request();
  }

  function validateToken (token) {
    var request = $http.post(host + '/validateToken', {
      token: token
    }).then(function() {
      return true;
    }, errorHandler);
    return request();
  }



  function errorHandler(error) {
    console.log('error: ', error);
  }

  return({
    login: login,
    validateToken: validateToken,
  });
});
