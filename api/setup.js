var config = require('./src/lib/config');

var orm = require('orm');
var ormTimestamps = require('orm-timestamps');
var ormTransaction = require('orm-transaction');
var ormPaging = require('orm-paging');

orm.connect(config.db.connectionString(), function(err, db) {
  if (err) throw err;

  db.use(ormPaging);
  db.use(ormTimestamps);
  db.use(ormTransaction);

  require('./src/models').config(db, db.models);

  db.drop(function() {
    db.sync(function() {
      db.models.user.create({phone: '+16043441795'}, function(err, user) {
        db.models.report.create({
          lat: 31.454671,
          lng: -100.486226,
          type: 'open-app',
          path : [
            { lat: 31.454671, lng: -100.486226 }
          ]
        }, function(err, report) {
          user.addReports(report, function(err, report) {
            process.exit();
          });
        });
      });
    });
  });
});