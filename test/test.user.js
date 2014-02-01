/* 
 * -------------------------------------------------------------------------------
 * test.user.js
 *
 * BDD testing of the routes used to manage users and roles.
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
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = require('./utils')
  , allUserNames = ['admin', 'guard', 'clerk', 'student', 'supervisor']
  , allUserAgents = [admin, guard, clerk, student, supervisor]
  ;

describe('User and Role Management', function(done) {
  before(function(done) {
    utils.loginMany(request, allUserNames, allUserAgents, function(err, success) {
      if (err) return done(err);
      if (success) return done();
      return done(new Error('Something went wrong.'));
    });
  });

  describe('access user list', function(done) {
    it('allowed to admin', function(done) {
      var req = request.get('/user');
      admin.attachCookies(req);
      req.expect(200, done);
    });

    it('disallowed to guard', function(done) {
      var req = request.get('/user');
      guard.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to clerk', function(done) {
      var req = request.get('/user');
      clerk.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to student', function(done) {
      var req = request.get('/user');
      student.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to supervisor', function(done) {
      var req = request.get('/user');
      supervisor.attachCookies(req);
      req.expect(403, done);
    });
  });

  describe('access role list', function(done) {
    it('allowed to admin', function(done) {
      var req = request.get('/role');
      admin.attachCookies(req);
      req.expect(200, done);
    });

    it('disallowed to guard', function(done) {
      var req = request.get('/role');
      guard.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to clerk', function(done) {
      var req = request.get('/role');
      clerk.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to student', function(done) {
      var req = request.get('/role');
      student.attachCookies(req);
      req.expect(403, done);
    });

    it('disallowed to supervisor', function(done) {
      var req = request.get('/role');
      supervisor.attachCookies(req);
      req.expect(403, done);
    });
  });

  describe('user menu displayed', function(done) {
    it('shown to admin', function(done) {
      var req = request.get('/');
      admin.attachCookies(req);
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , found = false
            ;
          $('a').each(function(i, a) {
            if (a.attribs && a.attribs.href && a.attribs.href == '/user') {
              found = true;
              return false; // exit the each
            }
          });
          (found).should.be.true;
          done();
        });
    });

    it('not shown to guard', function(done) {
      var req = request.get('/');
      guard.attachCookies(req);
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , found = false
            ;
          $('a').each(function(i, a) {
            if (a.attribs && a.attribs.href && a.attribs.href == '/user') {
              found = true;
              return false; // exit the each
            }
          });
          (found).should.be.false;
          done();
        });
    });

    it('not shown to clerk', function(done) {
      var req = request.get('/');
      clerk.attachCookies(req);
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , found = false
            ;
          $('a').each(function(i, a) {
            if (a.attribs && a.attribs.href && a.attribs.href == '/user') {
              found = true;
              return false; // exit the each
            }
          });
          (found).should.be.false;
          done();
        });
    });

    it('not shown to student', function(done) {
      var req = request.get('/');
      student.attachCookies(req);
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , found = false
            ;
          $('a').each(function(i, a) {
            if (a.attribs && a.attribs.href && a.attribs.href == '/user') {
              found = true;
              return false; // exit the each
            }
          });
          (found).should.be.false;
          done();
        });
    });

    it('not shown to supervisor', function(done) {
      var req = request.get('/');
      supervisor.attachCookies(req);
      req.expect(200)
        .end(function(err, res) {
          var $ = cheerio.load(res.text)
            , found = false
            ;
          $('a').each(function(i, a) {
            if (a.attribs && a.attribs.href && a.attribs.href == '/user') {
              found = true;
              return false; // exit the each
            }
          });
          (found).should.be.false;
          done();
        });
    });



  });


});






