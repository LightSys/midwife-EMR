/* 
 * -------------------------------------------------------------------------------
 * utils.js
 *
 * Helpers for testing.
 * ------------------------------------------------------------------------------- 
 */

var cfg = require('../config')
  , cheerio = require('cheerio')
  , _ = require('underscore')
  ;



/* --------------------------------------------------------
 * prepPost()
 *
 * GET the form in order to handle the csrf token correctly
 * and prepare the post request for the caller. Returns an
 * object containing the post request, 'postReq', and the
 * form data, 'formData', to the caller in order to continue
 * processing the post request.
 *
 * param       request - supertest request
 * param       agent - supertest agent
 * param       getPath - path to GET the form
 * param       formName - name of the form on the page gotten 
 * param       postPath - path to POST the form
 * param       postData - data to have the csrf token put into and returned
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
var prepPost = function(config, cb) {
  var request = config.request
    , agent = config.agent
    , getPath = config.getPath
    , formName = config.formName
    , postPath = config.postPath
    , postData = config.postData
    ;
  if (!request || !agent || !getPath || !formName || !postPath || !postData) {
    return new Error('Invalid configuration passed for prepPost()');
  }
  var req = request.get(getPath);
  agent.attachCookies(req);
  req.end(function(err, res) {
    var $ = cheerio.load(res.text)
      , csrf = $('input[name="_csrf"]', 'form[name="' + formName + '"]').attr('value')
      , data = {}
      ;
    data.formData = _.extend(postData, {_csrf: csrf})
    data.postReq = request.post(postPath)
    agent.saveCookies(res);
    agent.attachCookies(data.postReq);
    return cb(null, data);
  });
};

/* --------------------------------------------------------
 * login()
 *
 * Login to the application as a certain user.
 *
 * param       request - the supertest object
 * param       user - name of the user as a string
 * param       agent - supertest agent object
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
var login = function(request, user, agent, cb) {
  var userInfo = cfg.users[user]
    , config = {}
    ;
  if (! userInfo) return cb(new Error('User not found in config settings.'));
  config.request = request;
  config.agent = agent;
  config.getPath = '/login';
  config.formName = 'login';
  config.postPath = '/login';
  config.postData = userInfo;
  prepPost(config, function(err, data) {
    data.postReq
      .send(data.formData)
      .end(function(err2, res2) {
        if (err2) return cb(new Error('Unable to login.'));
        return cb(null, true);
      });
  });
};

var loginMany = function(request, users, agents, cb) {
  var pairs = _.zip(users, agents)
    , success = true
    , cnt = 0
    ;
  _.each(pairs, function(pair) {
    login(request, pair[0], pair[1], function(err, success) {
      if (err) {
        success = false;
      }
      cnt++;
      if (cnt == pairs.length) {
        return cb(null, success);
      }
    });
  });
};


module.exports = {
  login: login
  , loginMany: loginMany
  , prepPost: prepPost
};


