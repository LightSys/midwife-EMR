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
  , Event = require('../models').Event
  , Events = require('../models').Events
  , SelectData = require('../models').SelectData
  , SelectDatas = require('../models').SelectDatas
  ;

describe('Models', function(done) {

  describe('Patient', function(done) {
    it('should be able to create', function(done) {
      Patient.forge({updatedBy: 1})
        .setUpdatedBy(1)
        .setSupervisor(1)
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
        .setUpdatedBy(1)
        .setSupervisor(1)
        .save()
        .then(function(patient) {
          Pregnancy.forge({patient_id: patient.get('id')})
            .setUpdatedBy(1)
            .setSupervisor(1)
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

    it('should be able to create after calling required set fields', function(done) {
      Patient.forge({updatedBy: 1})
        .setUpdatedBy(1)
        .setSupervisor(1)
        .save()
        .then(function(patient) {
          Pregnancy.forge({generalInfo: 'Testing', patient_id: patient.get('id')})
            .setUpdatedBy(1)
            .setSupervisor(1)
            .save()
            .then(function(pregnancy) {
              done();
            })
            .caught(function(err) {
              done(new Error('Did not allow saving with required set fields.'));
            });
        })
        .caught(function(err) {
          done(err);
        });
    });

    it('should not be able to update without updatedBy', function(done) {
      var pregnancies = new Pregnancies()
        ;
      pregnancies.fetch()
        .then(function(pregs) {
          var preg = pregs.at(pregs.size() - 2);
          preg.set('note', 'Testing');
          preg.save()
            .then(function(saved) {
              done(new Error('Improperly allowed saving without updatedBy field in update.'));
            })
            .caught(function(err) {
              done();
            });
        });
    });

    it('should be able to retrieve pregnancies for a patient', function(done) {
      Patient.forge({updatedBy: 1})
        .setUpdatedBy(1)
        .setSupervisor(null)
        .save()
        .then(function(patient) {
          var preg1 = new Pregnancy({updatedBy: 1, patient_id: patient.get('id')})
            , preg2 = new Pregnancy({updatedBy: 1, patient_id: patient.get('id')})
            ;
          preg1
            .setUpdatedBy(1)
            .setSupervisor(null)
            .save()
            .then(function(p1) {
              preg2
                .setUpdatedBy(1)
                .setSupervisor(null)
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

  describe('Event', function(done) {
    it('should use loginEvent() to create a login event', function(done) {
      var note = Math.random()
        ;
      Event
        .loginEvent(1, note)
        .then(function(evt) {
          var id = evt.get('id')
            ;
          evt.get('note').should.eql(note);
          Event.forge({id: id}).fetch().then(function(model) {
            model.should.not.be.null;
            model.get('id').should.eql(id);
            done();
          });
        })
        .caught(function(err) {
          done(err);
        });
    });

    it('should use logoutEvent() to create a logout event', function(done) {
      var note = Math.random()
        ;
      Event
        .logoutEvent(1, note)
        .then(function(evt) {
          var id = evt.get('id')
            ;
          evt.get('note').should.eql(note);
          Event.forge({id: id}).fetch().then(function(model) {
            model.should.not.be.null;
            model.get('id').should.eql(id);
            done();
          });
        })
        .caught(function(err) {
          done(err);
        });
    });

    it('should use setSuperEvent() to create a supervisor event', function(done) {
      var note = Math.random()
        ;
      Event
        .setSuperEvent(1, note)
        .then(function(evt) {
          var id = evt.get('id')
            ;
          evt.get('note').should.eql(note);
          Event.forge({id: id}).fetch().then(function(model) {
            model.should.not.be.null;
            model.get('id').should.eql(id);
            done();
          });
        })
        .caught(function(err) {
          done(err);
        });
    });

    it('should use historyEvent() to create a history event', function(done) {
      var note = Math.random()
        ;
      Event
        .historyEvent(1, note)
        .then(function(evt) {
          var id = evt.get('id')
            ;
          evt.get('note').should.eql(note);
          Event.forge({id: id}).fetch().then(function(model) {
            model.should.not.be.null;
            model.get('id').should.eql(id);
            done();
          });
        })
        .caught(function(err) {
          done(err);
        });
    });

  });

  describe('selectData', function(done) {
    it('should get maritalStatus as JSON', function(done) {
      SelectData.getSelect('maritalStatus')
        .then(function(list) {
          list.should.be.an.instanceOf(Array);
          (list.length).should.be.above(5);
          list[0].should.have.property('selectKey');
          list[0].should.have.property('label');
          list[0].should.have.property('selected');
          list[0].should.not.have.property('id');
          list[0].should.not.have.property('updatedAt');
          list[0].should.not.have.property('updatedBy');
          list[0].should.not.have.property('supervisor');
          list[0].should.not.have.property('selected', 1);
          list[0].should.not.have.property('selected', 0);
          list[0].selected.should.be.type('boolean');
          done();
        })
        .caught(function(err) {
          done(err);
        });
    });

    it('should return empty array if name not found', function(done) {
      SelectData.getSelect('NotReallyThereAtAll')
        .then(function(list) {
          list.should.be.an.instanceOf(Array);
          list.should.have.property('length', 0);
          done();
        })
        .caught(function(err) {
          done(err);
        });
    });

  });

});




