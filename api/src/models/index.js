exports.config = function(db, models) {
  models.user = require('./user')(db);
  models.report = require('./report')(db);

  models.user.hasMany('reports', models.report, {

  },{
    key : true,
    autoFetch : true,
    autoFetchLimit : 1,
    reverse : 'user'
  });
};