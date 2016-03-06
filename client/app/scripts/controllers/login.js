'use strict';

angular.module('evaWebApp')
  .controller('LoginCtrl', function (api, $scope, $http, $location, $cookieStore) {
    $scope.authenticate = function() {
      $cookieStore.put('loggedin', true);
      $location.path('/');
    };

    $scope.login = function(username, password) {
      return $scope.authenticate();
      // return api.login(username, password);
    };

  });
