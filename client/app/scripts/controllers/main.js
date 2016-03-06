'use strict';

/**
 * @ngdoc function
 * @name evaWebApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the evaWebApp
 */
angular.module('evaWebApp')
  .controller('MainCtrl', function (api, sockets, $scope, $location, $cookieStore) {

    $scope.loggedIn = $cookieStore.get('loggedin');

    if ($scope.loggedIn === true) {
      console.log('logged in');
    } else {
      console.log('not logged in');
      $location.path('/login');
    }


  });
