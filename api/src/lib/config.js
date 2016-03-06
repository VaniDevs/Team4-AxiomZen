module.exports = {
  versions : ['v1'],
  origin : process.env.SOCKET_IO_ORIGIN,
  apiToken : process.env.EVA_API_TOKEN,
  db : {
    host : process.env.DB_HOST,
    user : process.env.DB_USER,
    pass : process.env.DB_PASS,
    name : process.env.DB_NAME,
    connectionString : function() {
      if (process.env.NODE_ENV === 'production') return process.env.JAWSDB_URL;

      return 'mysql://'+this.user+':'+this.pass+'@'+this.host+'/'+this.name;
    }
  },
  twilio : {
    number : process.env.TWILIO_NUMBER,
    accountSID : process.env.TWILIO_ACCOUNT_SID,
    authToken : process.env.TWILIO_AUTH_TOKEN
  }
};