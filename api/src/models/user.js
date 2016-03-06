module.exports = function(db) {
  return db.define('users', {
    phone : { type: 'text', unique : true, required: true },
    description : String,
    avatar : String,
    name : String,
    context: Object
  },{
    timestamp : true,
    methods : {

    },
    hooks : {
      beforeCreate : function() {
        this.context = {
          images : [

          ]
        };
      }
    }
  });
};