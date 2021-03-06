/*
 * -------------------------------------------------------------------------------
 * test.common.js
 *
 * BDD testing of the routes available to all roles.
 *
 * Note: set environmental variable NODE_ENV_VERBOSE=1 to see extra debugging info.
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
  , attending = supertest.agent(app)
  , attendingWithSuper = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = require('./utils')
  , allUserNames = ['admin', 'guard', 'clerk', 'attending', 'attending', 'supervisor']
  , allUserAgents = [admin, guard, clerk, attending, attendingWithSuper, supervisor]
  ;

describe('unauthenticated', function(done) {
  it('request to / redirects to logon page', function(done) {
    request
      .get('/')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('request to /search redirects to logon page', function(done) {
    request
      .get('/search')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('request to /user redirects to logon page', function(done) {
    request
      .get('/user')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('request to /role redirects to logon page', function(done) {
    request
      .get('/role')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('request to /role/1/edit redirects to logon page', function(done) {
    request
      .get('/role/1/edit')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('request to /profile redirects to logon page', function(done) {
    request
      .get('/profile')
      .expect('location', '/login')
      .expect(302, done);
  });

  it('anyone can display login page', function(done) {
    request
      .get('/login')
      .expect(200, done);
  });
});

describe('authenticated', function(done) {
  this.timeout(5000);
  before(function(done) {
    utils.loginMany(request, allUserNames, allUserAgents, function(err, success) {
      if (err) return done(err);
      if (! success) return done(new Error('Something went wrong!'));

      utils.setSuper(request, attendingWithSuper, function(err, success) {
        if (err) return done(err);
        if (! success) return done('setSuper() failed');
        done();
      });
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

    it('by attending', function(done) {
      var req = request.get('/');
      attending.attachCookies(req);
      req.expect(302, done);    // redirects to set supervisor after login
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
      req.expect(403, done);
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

    it('by attending', function(done) {
      var req = request.get('/search');
      attending.attachCookies(req);
      req.expect(302, done);    // attending have to set their supervisor first
    });

    it('by supervisor', function(done) {
      var req = request.get('/search');
      supervisor.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('conduct search', function(done) {
    var config = {}
      , data = {}
      ;

    this.timeout(5000);

    beforeEach(function(done) {
      data = {
        lastname: 'Tester'
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
        if (err) done(err);
        postInfo.postReq
          .send(postInfo.formData)
          .expect(403, done);
      });
    });

    it('guard by name', function(done) {
      config.agent = guard;
      utils.prepPost(config, function(err, postInfo) {
        if (err) done(err);
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('clerk by name', function(done) {
      config.agent = clerk;
      utils.prepPost(config, function(err, postInfo) {
        if (err) done(err);
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });

    it('attending by name', function(done) {
      config.agent = attending;
      utils.setSuper(request, config.agent, function(err, success) {
        if (err) return done(err);
        utils.prepPost(config, function(err, postInfo) {
          if (err) done(err);
          postInfo.postReq
            .send(postInfo.formData)
            .expect(200, done);
        });
      });
    });

    it('supervisor by name', function(done) {
      config.agent = supervisor;
      utils.prepPost(config, function(err, postInfo) {
        if (err) done(err);
        postInfo.postReq
          .send(postInfo.formData)
          .expect(200, done);
      });
    });
  });

  describe('access profile page', function(done) {

    it('by admin', function(done) {
      var req = request.get('/profile');
      admin.attachCookies(req);
      req.expect(200, done);
    });

    it('by guard', function(done) {
      var req = request.get('/profile');
      guard.attachCookies(req);
      req.expect(200, done);
    });

    it('by clerk', function(done) {
      var req = request.get('/profile');
      clerk.attachCookies(req);
      req.expect(200, done);
    });

    it('by attending', function(done) {
      var req = request.get('/profile');
      attending.attachCookies(req);
      req.expect(200, done);
    });

    it('by supervisor', function(done) {
      var req = request.get('/profile');
      supervisor.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('change profile', function(done) {
    this.timeout(5000);
    var formName = 'form[name="profileForm"]'
      , elements = ['id','_csrf','firstname','lastname','email']
      , data = {}
      ;

    var runTest = function(agent, newId, done) {
      var req
      , postReq
      , req2
      ;

      // --------------------------------------------------------
      // newId allows tests regarding illegally trying to update
      // a profile belonging to someone else.
      // --------------------------------------------------------
      if (done === undefined && typeof newId === 'function') {
        done = newId;
        newId = void(0);
      }
      // --------------------------------------------------------
      // Get the profile form and scrape the data.
      // --------------------------------------------------------
      req = agent.get('/profile');
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , origLastname
            , newLastname
            ;
          _.map(elements, function(fld) {
            var input = 'input[name="' + fld + '"]';
            data[fld] = $(input, formName).attr('value')
          });

          // --------------------------------------------------------
          // Change a field for testing.
          // --------------------------------------------------------
          origLastname = data.lastname;
          newLastname = moment().format();
          data.lastname = newLastname;
          if (newId) {
            data.id = newId;
          }

          // --------------------------------------------------------
          // Save to the database then verify the result.
          // --------------------------------------------------------
          postReq = agent.post('/profile');
          postReq
            .send(data)
            .end(function(err2, res2) {
              if (err2) return done(err2);
              if (newId) {
                res2.status.should.eql(403);
                return done();
              } else {
                res2.status.should.eql(302);
              }
              req2 = agent.get('/profile');
              req2.expect(200)
                .end(function(err3, res3) {
                  var $$ = cheerio.load(res3.text)
                    , lastname = $$('input[name="lastname"]', formName).attr('value')
                    ;
                  if (err3) return done(err3);
                  lastname.should.eql(newLastname);
                  done();
                });
            });
        });
    };

    beforeEach(function(done) {
      data = {password: '', password2: ''};
      done();
    });

    it('admin can update profile', function(done) {
      runTest(admin, done);
    });

    it('clerk can update profile', function(done) {
      runTest(clerk, done);
    });

    it('guard can update profile', function(done) {
      runTest(guard, done);
    });

    it('attending can update profile', function(done) {
      runTest(attendingWithSuper, done);
    });

    it('supervisor can update profile', function(done) {
      runTest(supervisor, done);
    });

    it('admin cannot update profile for guard', function(done) {
      runTest(admin, 2, done);
    });

    it('guard cannot update profile for clerk', function(done) {
      runTest(guard, 3, done);
    });

    it('clerk cannot update profile for attending', function(done) {
      runTest(clerk, 4, done);
    });

    it('attending cannot update profile for supervisor', function(done) {
      runTest(attendingWithSuper, 5, done);
    });

    it('supervisor cannot update profile for admin', function(done) {
      runTest(supervisor, 1, done);
    });

  });

  describe('logout destroys session', function(done) {
    var test = function(agent, done) {
      var req = request.get('/logout');
      agent.attachCookies(req);
      req
        .expect(302)
        .end(function(err, res) {
          var req2 = request.get('/');
          agent.attachCookies(req2);
          req2
            .expect(302)
            .expect('location', '/login', done);
        });
    };

    it('admin', function(done) {
      test(admin, done);
    });

    it('guard', function(done) {
      test(guard, done);
    });

    it('clerk', function(done) {
      test(clerk, done);
    });

    it('attending', function(done) {
      test(attending, done);
    });

    it('supervisor', function(done) {
      test(supervisor, done);
    });
  });

});



