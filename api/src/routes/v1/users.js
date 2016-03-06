var errors = require('../../helpers/errors');
var twilio = require('../../helpers/twilio');
var storage = require('../../helpers/storage');
var jwt = require('../../helpers/jwt');
var phone = require('phone');
var math = require('mathjs');

var upload = storage.userUpload.single('photo');

module.exports = {
  get: function(req, res) {
    var id = req.params.id;
    if (id === req.user.id || !id) {
      res.status(200).json(req.user);
    } else {
      // TODO : Need to add roles who can query other people Only Admin should
      req.models.user.get(id, function(err, user) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        req.status(200).json(user);
      });
    }
  },
  authenticate: function(req, res) {
    var body = req.body;
    if (body.phone) {

      var details = phone(body.phone);
      if (!details || details.length == 0 ) return res.status(400).json(errors.authentication.invalidPhoneNumber);

      //console.log('Phone number Details : ', details);

      var formattedNumber = details[0];

      req.models.user
        .find({ phone: formattedNumber })
        .one(function(err, user) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          var verificationCode = math.random(1111, 9999).toString().substr(0,4);
          var identificationToken = jwt.token({
            code: verificationCode,
            phone: formattedNumber,
            newUser: !user
          });

          twilio
            .sendVerificationCode(formattedNumber, verificationCode)
            .then(function(sent) {
              if (sent) return res.status(200).json({
                token: identificationToken
              });

              res.status(400).json(errors.authentication.failedSendingVerificationCode);
            });
        });
    } else if (body.token && body.code) {

      var decoded = jwt.verify(body.token);
      if (!decoded) return res.status(400).json(errors.authentication.invalidToken);

      if (decoded.code !== body.code) return res.status(400).json(errors.authentication.invalidCode);

      if (decoded.newUser) {

        req.db.transaction(function(err, transaction) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          req.models.user.create({phone: decoded.phone}, function(err, user) {
            if (err) return res.status(400).json(errors.somethingWentWrong(err));

            transaction.commit(function(err) {
              if (err) return res.status(400).json(errors.somethingWentWrong(err));

              storage.createUserDirectory(user.id);

              res.status(200).json({
                user: user,
                token: jwt.sign(user)
              });
            });
          })
        });
      } else {
        req.models.user
          .find({ phone: decoded.phone })
          .one(function(err, user) {
            if (err) return res.status(400).json(errors.somethingWentWrong(err));

            res.status(200).json({
              user: user,
              token: jwt.sign(user)
            });
          });
      }
    } else {
      res.status(400).json(errors.params.invalid);
    }
  },
  update: function(req, res) {
    var id = req.user.id;
    var body = req.body;

    if (req.headers['content-type'] && req.headers['content-type'].indexOf('multipart/form') > -1 ) {
      upload(req, res, function (err) {
        if (err || !req.file) return res.status(400).json(errors.somethingWentWrong(err));

        var temp = JSON.parse(JSON.stringify(req.user.context));
        temp.images.push('user_'+id+'/'+req.file.filename);

        req.user.context = temp;

        req.user.save(function(err) {
          if (err) return res.status(400).json(errors.somethingWentWrong(err));

          res.status(200).json({
            file : 'user_'+id+'/'+req.file.filename
          });
        });
      });
    } else {
      if (body.name) req.user.name = body.name;
      if (body.description) req.user.description = body.description;

      req.user.save(function(err) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        res.status(200).json(req.user);
      });
    }
  },
  avatar: function(req, res) {
    var id = req.user.id;

    upload(req, res, function (err) {
      if (err || !req.file) return res.status(400).json(errors.somethingWentWrong(err));

      req.user.avatar = 'user_'+id+'/'+req.file.filename;

      req.user.save(function(err) {
        if (err) return res.status(400).json(errors.somethingWentWrong(err));

        res.status(200).json({
          file : 'user_'+id+'/'+req.file.filename
        });
      });
    });
  }
};