'use strict';

/**
 * @ngdoc service
 * @name evaWebApp.sockets
 * @description
 * # sockets
 * Factory in the evaWebApp.
 */
angular.module('evaWebApp')
  .factory('sockets', function ($rootScope) {
    // move this to config
    var socketConnectionLocation = 'http://172.18.147.108:3000';
    var socket = io.connect(socketConnectionLocation);
    return {
      on: function (eventName, callback) {
        if (socket) {
          socket.on(eventName, function () {
            var args = arguments;
            $rootScope.$apply(function () {
              callback.apply(socket, args);
            });
          });
        }
      },
      emit: function (eventName, data, callback) {
        if (socket) {
          socket.emit(eventName, data, function () {
            var args = arguments;
            $rootScope.$apply(function () {
              if (callback) {
                callback.apply(socket, args);
              }
            });
          })
        }
      }
    };
  });
