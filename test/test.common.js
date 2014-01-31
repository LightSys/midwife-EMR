/*
 * -------------------------------------------------------------------------------
 * test.common.js
 *
 * BDD testing of the routes available to all roles.
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
  , admin = supertest.agent(app)
  , guard = supertest.agent(app)
  , clerk = supertest.agent(app)
  , student = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , cfg = require('../config')
  , utils = require('./utils')
  , allUserNames = ['admin', 'guard', 'clerk', 'student', 'supervisor']
  , allUserAgents = [admin, guard, clerk, student, supervisor]
  ;

describe('unauthenticated', function(done) {
  it('redirect / to logon page', function(done) {
    request
      .get('/')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('redirect /search to logon page', function(done) {
    request
      .get('/search')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('redirect /user to logon page', function(done) {
    request
      .get('/user')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('redirect /role to logon page', function(done) {
    request
      .get('/role')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('redirect /role/1/edit to logon page', function(done) {
    request
      .get('/role/1/edit')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('redirect /profile to logon page', function(done) {
    request
      .get('/profile')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('display login page', function(done) {
    request
      .get('/login')
      .expect(200, done);
  });
});

describe('authenticated', function(done) {
  before(function(done) {
    utils.loginMany(request, allUserNames, allUserAgents, function(err, success) {
      if (err) return done(err);
      if (success) return done();
      return done(new Error('Something went wrong.'));
    });
  });

  describe('access home page', function(done) {

    it('by admin', function(done) {
      var req = request.get('/');
      admin.attachCookies(req);
      req.expect(200, done);
    });

    it('by guard', function(done) {
      var req = request.get('/');
      guard.attachCookies(req);
      req.expect(200, done);
    });

    it('by clerk', function(done) {
      var req = request.get('/');
      clerk.attachCookies(req);
      req.expect(200, done);
    });

    it('by student', function(done) {
      var req = request.get('/');
      student.attachCookies(req);
      req.expect(200, done);
    });

    it('by supervisor', function(done) {
      var req = request.get('/');
      supervisor.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('access search page', function(done) {

    it('by admin', function(done) {
      var req = request.get('/search');
      admin.attachCookies(req);
      req.expect(200, done);
    });

    it('by guard', function(done) {
      var req = request.get('/search');
      guard.attachCookies(req);
      req.expect(200, done);
    });

    it('by clerk', function(done) {
      var req = request.get('/search');
      clerk.attachCookies(req);
      req.expect(200, done);
    });

    it('by student', function(done) {
      var req = request.get('/search');
      student.attachCookies(req);
      req.expect(200, done);
    });

    it('by supervisor', function(done) {
      var req = request.get('/search');
      supervisor.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('post search', function(done) {
    var config = {}
      , data = {}
      ;
    beforeEach(function(done) {
      data = {
        name: 'Smith'
        , doh: ''
        , priority: ''
      };
      config = {
        request: request
        , agent: null
        , getPath: '/search'
        , formName: 'search'
        , postPath: '/search'
        , postData: data
      };
      done();
    });

    it('admin by name', function(done) {
      config.agent = admin;
      utils.prepPost(config, function(err, postInfo) {
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('guard by name', function(done) {
      config.agent = guard;
      utils.prepPost(config, function(err, postInfo) {
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('clerk by name', function(done) {
      config.agent = clerk;
      utils.prepPost(config, function(err, postInfo) {
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('student by name', function(done) {
      config.agent = student;
      utils.prepPost(config, function(err, postInfo) {
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('supervisor by name', function(done) {
      config.agent = supervisor;
      utils.prepPost(config, function(err, postInfo) {
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });
  });
});



