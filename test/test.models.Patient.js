/* 
 * -------------------------------------------------------------------------------
 * test.models.Patient.js
 *
 * Tests the DAO for the patients table.
 *
 * NOTE: this really is not that necessary since the Bookshelf unit tests cover
 * this, but this is more an exercise in learning how to use the Bookshelf library.
 * ------------------------------------------------------------------------------- 
 */

var should = require('should')
  , dbSettings = require('../config').database
  // TODO: make this easier
  , Bookshelf = (require('bookshelf').DB || require('../models/DB').init(dbSettings))
  , Patient = require('../models/Patient').Patient
  , Patients = require('../models/Patient').Patients
  ;

describe('Patient', function(done) {
  var testPatient1 = {
      firstname: 'Jenny'
      , lastname: 'Smith'
      , nickname: 'Jen'
    }
    , cleanupById
    ;

  cleanupById = function(id, done) {
    Patient.forge({id: id})
      .destroy()
      .then(function() {
        done();
      });
  };

  it('Insert', function(done) {
    var cleanupId
      ;
    after(function(done) {
      cleanupById(cleanupId, done);
    });

    Patient.forge(testPatient1)
      .save()
      .then(function(p) {
        p.query('where', 'id', '=', p.id)
          .fetch()
          .then(function(qp) {
            if (qp == null) return done('qp is null');
            qp.id.should.equal(p.id);
            cleanupId = p.id;
            return done();
          });
      });
  });


});


