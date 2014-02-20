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


var getFormFields = function(request, agent, path, formName, cb) {
  var req = request.get(path)
    ;
  agent.attachCookies(req);
  req.end(function(err, res) {
    if (err) return cb(err);
    var $ = cheerio.load(res.text)
      , inputs
      , flds = []
      ;
    inputs = $('input', 'form[name="' + formName + '"]');
    _.each(inputs, function(input) {
      if (input.attribs.type != 'submit') flds.push(input.attribs.name);
    });
    return cb(null, flds);
  });
};

/* --------------------------------------------------------
 * setSuper()
 *
 * Set the supervisor to the first one available for the 
 * student. Assumes that the student is already logged in.
 * Calls the callback with true as the second parameter
 * upon success.
 *
 * param       request - supertest request
 * param       agent - supertest agent representing the student
 * return      undefined
 * -------------------------------------------------------- */
var setSuper = function(request, student, cb) {
  var req = request.get('/setsuper');
  student.attachCookies(req);
  req
    .end(function(err, res) {
      var $ = cheerio.load(res.text)
        , opts = $('option', 'form[name="setSuperForm"]')
        , csrf = $('input[name="_csrf"]', 'form[name="setSuperForm"]').attr('value')
        , superId
        , req2
        , formData = {}
        ;
      if (err) return cb(err);

      // --------------------------------------------------------
      // Get the id of the first supervisor that is available.
      // --------------------------------------------------------
      if (opts && opts['0'] && opts['0'].attribs && opts['0'].attribs.value) {
        superId = opts['0'].attribs.value;

        // --------------------------------------------------------
        // Set the supervisor.
        // --------------------------------------------------------
        formData.supervisor = superId;
        formData._csrf = csrf;
        req2 = request.post('/setsuper');
        student.attachCookies(req2);
        req2
          .send(formData)
          .end(function(err2, res2) {
            var req3
              ;
            if (err2) return cb(err2);

            // --------------------------------------------------------
            // Proof of properly setting the supervisor is successfully
            // going to the search page.
            // --------------------------------------------------------
            req3 = request.get('/search');
            student.attachCookies(req3);
            req3
              .end(function(err3, res) {
                if (err3) return cb(err3);
                return cb(null, true);
              });
          });
      } else {
        return cb(new Error('Supervisor not found!'));
      }
    });
};


/* --------------------------------------------------------
 * prepPost()
 *
 * GET the form in order to handle the csrf token correctly
 * and prepare the post request for the caller. Returns an
 * object containing the post request, 'postReq', and the
 * form data, 'formData', to the caller in order to continue
 * processing the post request.
 *
 * Config object passed as first parameter must have the
 * following elements:
 * request - supertest request
 * agent - supertest agent
 * getPath - path to GET the form
 * formName - name of the form on the page gotten 
 * postPath - path to POST the form
 * postData - data to have the csrf token put into and returned
 *
 * param       config - object with required params noted above
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
    , req
    , msgs = []
    ;

  if (!request) msgs.push('config.request not specified.');
  if (!agent) msgs.push('config.agent not specified.');
  if (!getPath) msgs.push('config.getPath not specified.');
  if (!formName) msgs.push('config.formName not specified.');
  if (!postPath) msgs.push('config.postPath not specified.');
  if (!postData) msgs.push('config.postData not specified.');
  if (msgs.length) {
    console.error(msgs.join(', '));
    return cb(new Error('Invalid configuration: ' + msgs.join(', ')));
  }

  req = request.get(getPath);
  agent.attachCookies(req);
  req.end(function(err, res) {
    if (err) return cb(err);
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
    , cnt = 0
    ;
  _.each(pairs, function(pair) {
    login(request, pair[0], pair[1], function(err, success) {
      if (err) return cb(new Error('Login did not succeed for ' + pair[0]));
      cnt++;
      if (cnt == pairs.length) {
        return cb(null, true);
      }
    });
  });
};


module.exports = {
  login: login
  , loginMany: loginMany
  , prepPost: prepPost
  , setSuper: setSuper
  , getFormFields: getFormFields
};


