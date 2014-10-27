/* 
 * -------------------------------------------------------------------------------
 * test.user.js
 *
 * BDD testing of the routes used to manage users and roles.
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
  , Promise = require('bluebird')
  , supertest = require('supertest')
  , app = require('../index.js')
  , request = supertest(app)
  , admin = supertest.agent(app)
  , guard = supertest.agent(app)
  , clerk = supertest.agent(app)
  , attending = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = require('./utils')
  , User = require('../models').User
  , allUserNames = ['admin', 'guard', 'clerk', 'attending', 'supervisor']
  , allUserAgents = [admin, guard, clerk, attending, supervisor]
  ;

describe('User and Role Management', function(done) {
  this.timeout(5000);
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

    it('disallowed to attending', function(done) {
      var req = request.get('/user');
      attending.attachCookies(req);
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

    it('disallowed to attending', function(done) {
      var req = request.get('/role');
      attending.attachCookies(req);
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

    it('not shown to attending', function(done) {
      var req = request.get('/');
      attending.attachCookies(req);
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

  describe('getUserIdMap()', function(done) {
    var users
      ;
    before(function(done) {
      new Users().fetch().then(function(list) {
        users = list.toJSON();
        done();
      })
      .caught(function(err) {
        done(err);
      });
    });

    it('match size', function(done) {
      User.getUserIdMap().then(function(map) {
        _.size(map).should.equal(_.size(users));
        done();
      })
      .caught(function(err) {
        done(err);
      });
    });

    it('match contents', function(done) {
      User.getUserIdMap().then(function(map) {
        _.every(map, function(rec) {
          var userRec = _.findWhere(users, {id: rec.id})
            , success = true
            ;
          if (userRec.username !== rec.username) success = false;
          if (userRec.firstname !== rec.firstname) success = false;
          if (userRec.lastname !== rec.lastname) success = false;
          return success;
        }).should.be.true;
        done();
      })
      .caught(function(err) {
        done(err);
      });
    });
  });

  describe('getFieldById()', function(done) {
    var userMap
      ;
    before(function(done) {
      User.getUserIdMap().then(function(map) {
        userMap = map;
        done();
      })
      .caught(function(err) {
        done(err);
      });
    });

    it('can get username of user', function(done) {
      var id = _.keys(userMap)[0]
        , id2 = _.keys(userMap)[1]
        ;
      User.getFieldById(id, 'username').then(function(username) {
        userMap[id].username.should.equal(username);
        User.getFieldById(id2, 'username').then(function(username) {
          userMap[id2].username.should.equal(username);
          done();
        });
      })
      .caught(function(err) {
        done(err);
      });
    });

    it('can get firstname of user', function(done) {
      var id = _.keys(userMap)[0]
        , id2 = _.keys(userMap)[1]
        ;
      User.getFieldById(id, 'firstname').then(function(firstname) {
        userMap[id].firstname.should.equal(firstname);
        User.getFieldById(id2, 'firstname').then(function(firstname) {
          userMap[id2].firstname.should.equal(firstname);
          done();
        });
      })
      .caught(function(err) {
        done(err);
      });
    });

    it('can get lastname of user', function(done) {
      var id = _.keys(userMap)[0]
        , id2 = _.keys(userMap)[1]
        ;
      User.getFieldById(id, 'lastname').then(function(lastname) {
        userMap[id].lastname.should.equal(lastname);
        User.getFieldById(id2, 'lastname').then(function(lastname) {
          userMap[id2].lastname.should.equal(lastname);
          done();
        });
      })
      .caught(function(err) {
        done(err);
      });
    });

  });

});






