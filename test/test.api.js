/*
 * -------------------------------------------------------------------------------
 * test.api.js
 *
 * Test of the API interface.
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
  , attendingWithoutSuper = supertest.agent(app)
  , attendingWithSuper = supertest.agent(app)
  , supervisor = supertest.agent(app)
  , cheerio = require('cheerio')
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , utils = Promise.promisifyAll(require('./utils'))
  , allUserNames = ['admin', 'guard', 'clerk', 'attending', 'attending', 'supervisor']
  , allUserAgents = [admin, guard, clerk, attendingWithoutSuper, attendingWithSuper, supervisor]
  ;


describe('api', function(done) {
  var pregId = 422;
  var pregnancyUrl = '/api/history/pregnancy/' + pregId;

  describe('history', function(done) {
    this.timeout(7000);
    before(function(done) {
      utils.loginMany(request, allUserNames, allUserAgents, function(err, success) {
        if (err) return done(err);
        if (success) return done();
        return done(new Error('Something went wrong.'));
      });
    });

    describe('access', function(done) {
      it('admin should not', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        admin.attachCookies(req);
        req
          .expect(403, done);
      });
      it('clerk should not', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        clerk.attachCookies(req);
        req
          .expect(403, done);
      });
      it('guard should not', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        guard.attachCookies(req);
        req
          .expect(403, done);
      });
      it('attending should not', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        attendingWithSuper.attachCookies(req);
        req
          .expect(403, done);
      });
      it('supervisor should', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        supervisor.attachCookies(req);
        req
          .expect(200, done);
      });
    }); // end access

    describe('pregnancy', function(done) {
      it('JSON', function(done) {
        var req = request.get(pregnancyUrl)
          ;
        supervisor.attachCookies(req);
        req
          .expect(200)
          .end(function(err, res) {
            var json;
            if (err) return done(err);
            if (! res || ! res.text) return done('No Response');
            try {
              json = JSON.parse(res.text);
            } catch (e) {
              return done(e);
            }
            json.should.be.an.Array;
            json[0].should.have.a.property('pregnancy');
            json[0].should.have.a.property('patient');
            json[0].pregnancy.should.be.an.Object;
            json[0].patient.should.be.an.Object;
            done();
          });
      });
    }); // end pregnancy

  });   // end history
});     // end api

