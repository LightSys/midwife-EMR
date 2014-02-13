/*
 * -------------------------------------------------------------------------------
 * test.models.js
 *
 * Testing of the models and their relationships.
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
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , Patient = require('../models').Patient
  , Patients = require('../models').Patients
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  ;

describe('Models', function(done) {

  describe('Patient', function(done) {
    it('should be able to create', function(done) {
      Patient.forge({updatedBy: 1})
        .save()
        .then(function(model) {
          model.should.have.property('id');
          done();
        });
    });

    it('checkFields() should detect invalid fields', function(done) {
      var flds = {
            dob: 'sdfsdfs'  // invalid date
        }
        ;
      Patient.checkFields(flds).then(function(flds) {
        done(new Error('checkFields did not catch invalid field.'));
      })
      .caught(function(reasons) {
        done();
      });
    });

    it('checkFields() should allow valid fields', function(done) {
      var flds = {
            dob: '1988-12-03'  // a date
        }
        ;
      Patient.checkFields(flds).then(function(flds) {
        done();
      })
      .caught(function(reasons) {
        done(new Error('checkFields() did not allow valid fields.'));
      });
    });
  });

  describe('Pregnancy', function(done) {
    it('should be able to create', function(done) {
      Patient.forge({updatedBy: 1})
        .save()
        .then(function(patient) {
          Pregnancy.forge({updatedBy: 1, patient_id: patient.get('id')})
            .save()
            .then(function(pregnancy) {
              // --------------------------------------------------------
              // Confirm the save to the database.
              // --------------------------------------------------------
              Pregnancy.forge({id: pregnancy.get('id')})
                .fetch()
                .then(function(pregnancy2) {
                  pregnancy2.get('id').should.eql(pregnancy.get('id'));
                  pregnancy2.get('patient_id').should.eql(patient.get('id'));
                  done();
                });
            });
        });
    });

    it('should be able to retrieve pregnancies for a patient', function(done) {
      Patient.forge({updatedBy: 1})
        .save()
        .then(function(patient) {
          var preg1 = new Pregnancy({updatedBy: 1, patient_id: patient.get('id')})
            , preg2 = new Pregnancy({updatedBy: 1, patient_id: patient.get('id')})
            ;
          preg1
            .save()
            .then(function(p1) {
              preg2
                .save()
                .then(function(p2) {
                  Patient.forge({id: patient.get('id')})
                    .fetch({withRelated: 'pregnancies'})
                    .then(function(patient2) {
                      var pregs = patient2.related('pregnancies').toJSON()
                        , ids = _.pluck(pregs, 'id')
                        ;
                      pregs.should.have.length(2);
                      _.contains(ids, p1.get('id')).should.be.true;
                      _.contains(ids, p2.get('id')).should.be.true;
                      done();
                    });
                });
            })
        });
    });

    it('should be able to retrieve a patient for a pregnancy', function(done) {
      var pregs = new Pregnancies();
      pregs
        .fetch()
        .then(function(list) {
          return list.at(list.length - 1);    // last pregnancy
        })
        .then(function(pregnancy) {
          pregnancy
            .load(['patient'])
            .then(function(pregnancy) {
              var patient = pregnancy.related('patient').toJSON();
              patient.should.have.property('dob');
              pregnancy.get('patient_id').should.eql(patient.id);
              done();
            });
        });
    });

    it('checkFields should catch invalid fields.', function(done) {
      var flds = {
            firstname: ''
            , lastname: ''
        }
        ;
      Pregnancy.checkFields(flds).then(function(flds) {
        done(new Error('checkFields() did not detect invalid fields.'));
      })
      .catch(function(reasons) {
        done();
      });
    });

    it('checkFields should allow valid fields.', function(done) {
      var flds = {
            firstname: 'Jane'
            , lastname: 'Smith'
        }
        ;
      Pregnancy.checkFields(flds).then(function(flds) {
        done();
      })
      .catch(function(reasons) {
        done(new Error('checkFields() did not allow valid fields.'));
      });
    });
  });

});




