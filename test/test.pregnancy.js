/*
 * -------------------------------------------------------------------------------
 * test.pregnancy.js
 *
 * BDD testing of the routes that manage pregnancies.
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
  , Promise = require('bluebird')
  , app = require('../index.js')
  , request = supertest(app)
  , admin = supertest.agent(app)
  , guard = supertest.agent(app)
  , clerk = supertest.agent(app)
  , studentWithoutSuper = supertest.agent(app)
  , studentWithSuper = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = Promise.promisifyAll(require('./utils'))
  , allUserNames = ['admin', 'guard', 'clerk', 'student', 'student', 'supervisor']
  , allUserAgents = [admin, guard, clerk, studentWithoutSuper, studentWithSuper, supervisor]
  ;

describe('Pregnancy', function(done) {
  this.timeout(5000);

  before(function(done) {
    utils.loginManyAsync(request, allUserNames, allUserAgents)
      .then(function(success) {
        utils.setSuperAsync(request, studentWithSuper);
      })
      .then(function() {
        done();
      })
      .caught(function(e) {
        done(e);
      });
  });

  describe('can display the create pregnancy form', function(done) {
    it('admin should not', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      admin.attachCookies(req);
      req
        .expect(403, done);
    });

    it('guard should not', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      guard.attachCookies(req);
      req
        .expect(403, done);
    });

    it('clerk should', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      clerk.attachCookies(req);
      req
        .expect(200, done);
    });

    it('supervisor should', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      supervisor.attachCookies(req);
      req
        .expect(200, done);
    });

    it('student should not without supervisor', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      studentWithoutSuper.attachCookies(req);
      req
        .expect(302)
        .expect('location', '/setsuper', done);
    });

    it('student should with supervisor', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      studentWithSuper.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('create new record', function(done) {
    it('pregnancy record with empty fields will not save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          //postData.dob = '1988-12-31';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(406, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('pregnancy record with patient dob but empty pregnancy fields will not save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          postData.dob = '1988-12-31';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(406, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('pregnancy record with proper fields will save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          postData.dob = '1988-12-31';
          postData.firstname = 'Sally';
          postData.lastname = 'Tester';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(302, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

  });

  describe('can display the history page', function(done) {
    it('admin should not', function(done) {
      var req = request.get('/pregnancy/1/history')
        ;
      admin.attachCookies(req);
      req
        .expect(403, done);
    });

    it('guard should not', function(done) {
      var req = request.get('/pregnancy/1/history')
        ;
      guard.attachCookies(req);
      req
        .expect(403, done);
    });

    it('student should not', function(done) {
      var req = request.get('/pregnancy/1/history')
        ;
      studentWithSuper.attachCookies(req);
      req
        .expect(403, done);
    });

    it('clerk should not', function(done) {
      var req = request.get('/pregnancy/1/history')
        ;
      clerk.attachCookies(req);
      req
        .expect(403, done);
    });

    it('supervisor should', function(done) {
      var req = request.get('/pregnancy/1/history')
        ;
      supervisor.attachCookies(req);
      req
        .expect(200, done);
    });

  });
});



