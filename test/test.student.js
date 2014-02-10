/*
 * -------------------------------------------------------------------------------
 * test.student.js
 *
 * BDD testing of the routes pertaining to students.
 * -------------------------------------------------------------------------------
 */

// --------------------------------------------------------
// Sanity check - only run with a test configuration.
// --------------------------------------------------------
if (process.env.NODE_ENV !== 'test') {
  console.error('Not using the "test" environment...aborting!');
  process.exit(1);
}

var should = require('should')
  , supertest = require('supertest')
  , app = require('../index.js')
  , request = supertest(app)
  , student = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = require('./utils')
  , allUserNames = ['student', 'supervisor']
  , allUserAgents = [student, supervisor]
  ;


describe('Student roles', function(done) {

  describe('authentication', function(done) {

    it('should redirect to set supervisor after login', function(done) {
      var userInfo = cfg.users['student']
        , config = {}
        ;
      config.request = request;
      config.agent = student;
      config.getPath = '/login';
      config.formName = 'login';
      config.postPath = '/login';
      config.postData = userInfo;
      utils.prepPost(config, function(err, data) {
        data.postReq
          .send(data.formData)
          .expect(302)
          .expect('location', '/')
          .end(function(err2, res2) {
            if (err2) return done(err2);
            var req2 = request.get('/');
            student.attachCookies(req2);
            req2
              .expect(302)
              .expect('location', '/setsuper', done);
          });
      });
    });

  });

  describe('setting supervisor', function(done) {
    before(function(done) {
      utils.loginMany(request, allUserNames, allUserAgents, function(err, success) {
        if (err) return done(err);
        if (success) return done();
        return done(new Error('Something went wrong.'));
      });
    });

    it('should be able to set a supervisor', function(done) {
      var req = request.get('/setsuper');
      student.attachCookies(req);
      req
        .expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , opts = $('option', 'form[name="setSuperForm"]')
            , csrf = $('input[name="_csrf"]', 'form[name="setSuperForm"]').attr('value')
            , superId
            , req2
            , formData = {}
            ;
          if (err) return done(err);

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
              .expect(302)
              .expect('location', '/setsuper')
              .end(function(err2, res2) {
                var req3
                  ;
                if (err2) return done(err2);

                // --------------------------------------------------------
                // Proof of properly setting the supervisor is successfully
                // going to the search page.
                // --------------------------------------------------------
                req3 = request.get('/search');
                student.attachCookies(req3);
                req3
                  .expect(200, done);
              });
          } else {
            return done(new Error('Supervisor not found!'));
          }
        });
    });

    it('setSuper() in utils.js should set supervisor', function(done) {
      var student = supertest.agent(app)
        , req = request.get('/setsuper')
        ;
      utils.login(request, 'student', student, function(err, success) {
        if (err) return done(err);
        if (! success) return done(new Error('utils.login() failed'));
        utils.setSuper(request, student, function(err, success) {
          var reqTest = request.get('/')
            ;
          if (err) return done(err);
          if (! success) return done(new Error('utils.setSuper() failed'));

          // --------------------------------------------------------
          // Only a student with a supervisor can get to the main page
          // without being redirected to choose a supervisor.
          // --------------------------------------------------------
          student.attachCookies(reqTest);
          reqTest
            .expect(200, done);
        });
      });
    });

  });

});



