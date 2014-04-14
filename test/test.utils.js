/* 
 * -------------------------------------------------------------------------------
 * test.utils.js
 *
 * Testing of the helper functions we use.
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


describe('Utils', function(done) {
  this.timeout(5000);

  describe('GetFormFields()', function(done) {
    before(function(done) {
      utils.loginManyAsync(request, allUserNames, allUserAgents)
        .then(function(success) {
          utils.setSuperAsync(request, attendingWithSuper);
        })
        .then(function() {
          done();
        })
        .catch(function(e) {
          done(e);
        });
    });

    it('Gets all input field names', function(done) {
      var path = cfg.path.userNewForm
        , formName = 'userForm'
        ;
      utils.getFormFieldsAsync(request, admin, path, formName)
        .then(function(fldNames) {
          fldNames.should.be.an.instanceOf(Array).and.have.length(9);
          fldNames.should.contain('username');
          fldNames.should.contain('firstname');
          fldNames.should.contain('lastname');
          fldNames.should.contain('password');
          fldNames.should.contain('password2');
          fldNames.should.contain('email');
          fldNames.should.contain('note');
          fldNames.should.contain('_csrf');
          fldNames.should.contain('status');
          done();
        })
        .catch(function(e) {
          done(e);
        });
    });
  });

});




