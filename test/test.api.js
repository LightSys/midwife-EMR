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
  var prenatalUrl = '/api/history/pregnancy/' + pregId + '/prenatal';

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
        var req = request.get(prenatalUrl)
          ;
        admin.attachCookies(req);
        req
          .expect(403, done);
      });
      it('clerk should not', function(done) {
        var req = request.get(prenatalUrl)
          ;
        clerk.attachCookies(req);
        req
          .expect(403, done);
      });
      it('guard should not', function(done) {
        var req = request.get(prenatalUrl)
          ;
        guard.attachCookies(req);
        req
          .expect(403, done);
      });
      it('attending should not', function(done) {
        var req = request.get(prenatalUrl)
          ;
        attendingWithSuper.attachCookies(req);
        req
          .expect(403, done);
      });
      it('supervisor should', function(done) {
        var req = request.get(prenatalUrl)
          ;
        supervisor.attachCookies(req);
        req
          .expect(200, done);
      });
    }); // end access

    describe('prenatal', function(done) {
      it('JSON', function(done) {
        var req = request.get(prenatalUrl)
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
            json[0].should.have.a.property('pregnancyLog');
            json[0].should.have.a.property('patientLog');
            json[0].should.have.a.property('riskLog');
            json[0].should.have.a.property('replacedAt');
            json[0].pregnancyLog.should.be.an.Object;
            json[0].patientLog.should.be.an.Object;
            json[0].riskLog.should.be.an.Object;
            done();
          });
      });
    }); // end prenatal
  });   // end history
});     // end api

