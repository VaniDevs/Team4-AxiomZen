module.exports = function(db) {
  return db.define('reports', {
    lat : { type: 'number', big: true, required: true },
    lng : { type: 'number', big: true, required: true },
    status : { type : 'text', defaultValue: 'reported' },
    reviewed : Boolean,
    type: String,
    images : Object,
    path : Object
  },{
    timestamp : true,
    methods : {
    }
  });
};