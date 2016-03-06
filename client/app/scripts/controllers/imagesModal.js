'use strict';

/**
 * @ngdoc function
 * @name evaWebApp.controller:ImagesmodalCtrl
 * @description
 * # ImagesmodalCtrl
 * Controller of the evaWebApp
 */
angular.module('evaWebApp')
  .controller('ImagesModalCtrl', function ($scope, dataArray) {
    $scope.dataArray = dataArray;
    console.log('$scope is in inside', $scope);



    $scope.close = function(result) {
    	close(result, 500); // close, but give 500ms for bootstrap to animate
    };
  });
