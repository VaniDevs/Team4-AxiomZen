var storage = require('../../helpers/storage');
var errors = require('../../helpers/errors');
var twilio = require('../../helpers/twilio');

var orm = require('orm');

var upload = storage.upload.single('photo');

module.exports = {
  get: function(req, res) {
    // ...
  },
  add: function(req, res) {
    var body = req.body;

    req.db.transaction(function(err, transaction) {
      if (err) return res.status(400).json(errors.somethingWentWrong(err));

      req.models.report.create({
        lat : body.lat,
        lng : body.lng,
        type : body.type,
        path : [
          { lat: body.lat, lng: body.lng }
        ]
      }, function(err, report) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        req.user.addReports(report, function(err) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          report.user = [ req.user ];

          transaction.commit(function(err) {
            if (err) return res.status(400).json(errors.somethingWentWrong(err));

            twilio.sendMessage(req.user.phone, 'Are you okay? Help is on the way! let us know if you are ok: eva-emergency://sms/ok');

            storage.createReportDirectory(report.id);

            // TODO :
            var socket = require('../../helpers/socket.io');
            socket.report(report);

            res.status(200).json(report);
          });
        });
      });
    });
  },
  update: function(req, res) {
    var id = req.params.id;
    var body = req.body;

    if (req.headers['content-type'] && req.headers['content-type'].indexOf('multipart/form') > -1 ) {
      upload(req, res, function (err) {
        if (err || !req.file) return res.status(400).json(errors.somethingWentWrong(err));
        console.log('report_'+id+'/'+req.file.filename);
        req.models.report.get(id, function(err, report) {
          if (err || !req.file) return res.status(400).json(errors.somethingWentWrong(err));

          if (!report.images) {
            report.images = [];
          }

          var temp = JSON.parse(JSON.stringify(report.images));
          temp.push('report_'+id+'/'+req.file.filename);

          report.images = temp;

          report.save(function(err) {
            if (err) return res.status(400).json(errors.somethingWentWrong(err));

            // TODO :
            var socket = require('../../helpers/socket.io');
            socket.update(report);

            res.status(200).json({
              file : 'report_'+id+'/'+req.file.filename
            });
          });
        });
      });
    } else {
      req.models.report.get(id, function(err, report) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        if (body.lat && body.lng) {
          report.path.push({
            lat : body.lat,
            lng : body.lng
          });
        }

        report.save(function(err) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          res.status(200).json(report);
        });
      });
    }
  },
  cancelPreviousReport: function(req, res) {
    req.models.report
      .find({ status : orm.ne('resolved') })
      .order('-created_at')
      .one(function(err, report) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        report.status = 'close-by-user';
        report.save(function(err) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          res.status(200).end();
        });
    });
  }
};