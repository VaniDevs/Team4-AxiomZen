module.exports = {
  handleMessage: function(req, res) {

    console.log(req.body);

    res.status(200).end();
  }
};