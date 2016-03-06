module.exports = {
  params: {
    invalid: {
      code: 999,
      msg: 'Invalid or Missing Parameters'
    }
  },
  authentication: {
    invalidPhoneNumber: {
      code: 1000,
      msg: 'Invalid Phone Number.'
    },
    failedSendingVerificationCode: {
      code: 1001,
      msg: 'Failed Sending Verification Code.'
    },
    invalidToken: {
      code: 1002,
      msg: 'Invalid Token.'
    },
    invalidCode: {
      code: 1003,
      msg: 'Invalid Code.'
    }
  },
  somethingWentWrong: function(err) {
    console.log(err);

    return {
      code: 998,
      msg: 'Something Went Wrong.',
      err: err
    }
  }
};