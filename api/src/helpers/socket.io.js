var config = require('../lib/config');
var app = require('../lib/app');
var orm = require('orm');

var io = null;
var active = {};

function _setup() {
  io.on('connection', function(socket) {
    active[socket.id] = socket;

    app.models.report
      .find({ reviewed : false })
      .all(function(err, reports) {

        socket.emit('initialize', {
          reports : reports
        });
      });

    socket.on('report:update', function(payload) {

      app.models.report
        .get(payload.id, function(err, report) {
          if (err) return socket.emit('admin:error', { msg : 'Something Wrong! Failed to update report.' });

          if (payload.status) report.status = payload.status;
          if (payload.reviewed) report.reviewed = payload.reviewed;

          report.save(function(err) {
            if (err) return socket.emit('admin:error', { msg : 'Something Wrong! Failed to update report.' });

            io.emit('report:update', report);
          });
      });
    });
  });

  io.on('disconnect', function(socket) {
    delete active[socket.id];
  });
}

exports.setup = function(server) {
  io = require('socket.io')(server);

  _setup();

  io.set('origins', config.origin);
};

exports.report =  function(report) {
  io.emit('report:new', report);
};

exports.update =  function(report) {
  io.emit('report:update', report);
};
