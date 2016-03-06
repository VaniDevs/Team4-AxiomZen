'use strict';

/**
 * @ngdoc overview
 * @name evaWebApp
 * @description
 * # evaWebApp
 *
 * Main module of the application.
 */
angular
  .module('evaWebApp', [
    'angularMoment',
    'angularModalService',
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html'
      })
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl',
        controllerAs: 'about'
      })
      .when('/login', {
        templateUrl: 'views/login.html',
        controller: 'LoginCtrl',
        controllerAs: 'auth'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
