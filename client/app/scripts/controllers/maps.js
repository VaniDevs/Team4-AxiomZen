'use strict';

/**
 * @ngdoc function
 * @name evaWebApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the evaWebApp
 */
angular.module('evaWebApp')
  .controller('MapsCtrl', function ($http, $scope, sockets, moment, ModalService) {
    // ------- SETUP ------- //
    var STATUS_CHANGES = {
      'reported': 'dispatched',
      'dispatched': 'resolved'
    };

    var infoWindow;
    var initializeMap = function() {
      $scope.map = new google.maps.Map(document.getElementById('map'), {
        zoom: 14,
        center: new google.maps.LatLng(49.246292, -123.116226),
        mapTypeId: google.maps.MapTypeId.TERRAIN
      });

      $scope.markers = [];

      infoWindow = new google.maps.InfoWindow();
    };

    initializeMap();

    function loadImage(url, cb) {
      $http({
        method: 'Get',
        headers : {
          'x-api-token' : 'd0bacab2-e412-4f77-8e5d-3b3c7475a750'
        },
        url: url,
        responseType: 'arraybuffer',
        cache: 'true'
      })
        .success(function(data) {
          var arr = new Uint8Array(data);

          var raw = '';
          var i, j, subArray, chunk = 5000;
          for (i = 0, j = arr.length; i < j; i += chunk) {
            subArray = arr.subarray(i, i + chunk);
            raw += String.fromCharCode.apply(null, subArray);
          }

          var b64 = btoa(raw);

          cb(b64);
        })
        .error(function() {
          cb('');
        });
    }

    // ------- GOOGLE MAPS HELPER FUNCTIONS ------- //

    var createMarker = function(info) {
      var user = info.user[0];
      var name = (user) ? user.name : '';
      var phone = (user) ? user.phone : 'No title';
      var imageLinks = info.images || [];

      var marker = new google.maps.Marker({
        map: $scope.map,
        position: new google.maps.LatLng(info.lat, info.lng),
        title: phone
      });

      var time = moment(info.modified_at).format('h:mm:ss a');

      marker.id = info.id;
      marker.status = info.status;
      marker.imageLinks = imageLinks;

      google.maps.event.addListener(marker, 'click', function() {
        loadImage('http://90888a61.ngrok.io/api/img/'+info.user[0].avatar, function(b64) {
          var content =
            '<div class="infoWindowContent">' +
            '<img style="background-color: black;" width="80" height="80" src="data:image/jpeg;base64,'+b64+'">' +
            '<hr>'+
            '<b>Name:</b> ' + name +
            '<br><b>Number:</b> ' + phone +
            '<br/><b>Time:</b> ' + time +
            '<br/><b>Status:</b> ' + info.status +
            '<br/><b>Type:</b> ' + (info.type || '') +
            '</div>';

          infoWindow.setContent('<h4>Help Request</h3>' + content);
          infoWindow.open($scope.map, marker);
        });
      });

      return marker;
    };

    var updateReport = function(i, report) {
      $scope.markers[i].setMap(null);
      $scope.markers[i] = createMarker(report);
    };

    var removeReport = function(i) {
      $scope.markers[i].setMap(null);
      $scope.markers.splice(i, 1);
    };

    var zoomInOnFirstMarker = (function() {
      var bool = true;
      return function(marker) {
        if (bool) {
          bool = false;
          $scope.map.panTo(marker.position);
        }
      }
    })();

    // ------- SOCKETS ------- //

    sockets.on('initialize', function(payload) {
      console.log('initialize', payload);

      payload.reports.forEach(function(report) {
        var marker = createMarker(report);
        zoomInOnFirstMarker(marker);
        $scope.markers.push(marker);
      });
    });

    sockets.on('report:new', function(report) {
      console.log('report:new', report);

      $scope.markers.push(createMarker(report));
    });

    sockets.on('report:update', function(report) {
      console.log('report:update', report);

      $scope.markers.forEach(function(marker, i) {
        if (marker.id === report.id) {
          if (report.status == 'resolved') {
            // remove the marker from the scope
            // remove if report is cleared
            removeReport(i);

            console.log('scope markers: ', $scope.markers);
          } else {
            // otherwise, remove and replace
            updateReport(i, report);
          }
        }
      });
    });

    sockets.on('admin:error', function(error) {
      console.log('report:update', error);
    });

    // ------- SCOPE ONCLICK FUNCTIONS ------- //

    $scope.openInfoWindow = function(e, selectedMarker) {
      console.log('e is', e);
      e.preventDefault();
      // add selected class to item
      $scope.selected = selectedMarker;

      // center on the marker
      $scope.map.panTo(selectedMarker.getPosition());
      $scope.map.setZoom(14);
      // display the content
      google.maps.event.trigger(selectedMarker, 'click');
    };

    $scope.reviewed = function(selected) {
      $scope.markers.forEach(function(marker, index) {
        if (marker.id === selected.id) removeReport(index);
      });

      sockets.emit('report:update', {
        id: selected.id,
        reviewed: true
      });
    };

    $scope.update = function(e, marker) {
      console.log('e is', e);
      console.log('update report', marker);

      sockets.emit('report:update', {
        id: marker.id,
        status: STATUS_CHANGES[marker.status]
      });
    };

    $scope.showAModal = function(stringArray) {
      $scope.dataArray = [];
      if(!stringArray || stringArray.length === 0 ||
        stringArray === null || stringArray === undefined) {
        // do nothing
      }
      else {
        stringArray.forEach(function(imageLink, i) {
          $scope.dataArray.push({
            id: i,
            dataString: ''
          });
          // load the image async
          loadImage('http://90888a61.ngrok.io/api/img/' + imageLink, function(b64) {
            // base uri
            var string = 'data:image/jpeg;base64,' + b64;
            $scope.dataArray.forEach(function(data, index) {
              if (data.id == i) {
                $scope.dataArray[index].dataString = string;
              }
            })
          });
          console.log('$scope is in maps', $scope);
        });
      }

      // Just provide a template url, a controller and call 'showModal'.
      ModalService.showModal({
        templateUrl: "views/imagesModal.html",
        controller: "ImagesModalCtrl",
        inputs: {
          dataArray: $scope.dataArray
        }
      }).then(function(modal) {
      // The modal object has the element built, if this is a bootstrap modal
      // you can call 'modal' to show it, if it's a custom modal just show or hide
      // it as you need to.

        // call this to load the modal.
        modal.element.modal();

        modal.close.then(function(result) {
          $scope.message = result ? "You said Yes" : "You said No";
        });
      });

    };


  });
