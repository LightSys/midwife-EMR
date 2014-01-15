/* 
 * -------------------------------------------------------------------------------
 * test.Patient.js
 *
 * Testing the Patient interface.
 * ------------------------------------------------------------------------------- 
 */

var should = require('should')
  , _ = require('underscore')
  , dbSettings = require('../config').database
  // TODO: make this easier
  , Bookshelf = (require('bookshelf').DB || require('../models/DB').init(dbSettings))
  , Patient = require('../models/Patient').Patient
  , Patients = require('../models/Patient').Patients
  , patient = require('../lib/health').patient
  ;



describe('Patient', function() {
  var testPatient1 = {
      firstname: 'Jenny'
      , lastname: 'Smith'
      , dob: '1990-11-23'
      , mmcID: '13-00-01'
    }
    , testPatient2 = {
      firstname: 'Susan'
      , lastname: 'Jones'
      , nickname: 'Sue'
    }
    , testPatient3 = {
      firstname: 'Charity'
      , lastname: 'Abaline'
      , nickname: 'Charleen'
    }
    , delIds = []
    ;

  afterEach(function(done) {
    var whenDone = _.after(delIds.length, function() {
      done();
    });
    delIds.forEach(function(id) {
      Patient.forge({id: id})
        .destroy();
      whenDone();
    });
  });

  it('Create', function(done) {
    patient.create(testPatient1, function(err, id) {
      if (err) return done(err);
      id.should.be.type('number');

      // --------------------------------------------------------
      // Verify that the record is in the database.
      // --------------------------------------------------------
      Patient.forge({id: id})
        .fetch()
        .then(function(model) {
          if (! model) return done('Record not created');
          delIds.push(id);
          done();
        });
    });
  });

  it('Delete', function(done) {
    Patient.forge(testPatient1)
      .save()
      .then(function(model) {
        patient.delete(model.id, function(err) {
          if (err) return done(err);
          return done();
        });
      });
  });

  it('Find multiple records by an attribute', function(done) {
    Patient.forge(testPatient3)
      .save()
      .then(function(p1) {
        delIds.push(p1.id);
        Patient.forge(testPatient2)
          .save()
          .then(function(p2) {
            delIds.push(p2.id);
            Patient.forge(testPatient3)
              .save()
              .then(function(p3) {
                delIds.push(p3.id);
                patient.find({nickname: testPatient3.nickname}, function(err, p) {
                  var whenDone = _.after(p.length, function() {done();});
                  if (err) return done(err);
                  p.should.be.an.instanceOf(Array);
                  p.should.have.property('length', 2);
                  p.forEach(function(pat) {
                    testPatient3.nickname.should.equal(pat.nickname);
                    whenDone();
                  })
                });
              });
          });
      });
  });

  it('Update a record', function(done) {
    Patient.forge(testPatient2)
      .save()
      .then(function(p1) {
        var data = {
          id: p1.id
          , firstname: 'Mandy'
          , nickname: 'Man'
          , generalInfo: 'This is a test'
        };
        delIds.push(p1.id);
        patient.update(data, function(err) {
          if (err) done(err);
          Patient.forge({id: p1.id})
            .fetch()
            .then(function(p2) {
              p2.get('firstname').should.equal(data.firstname);
              p2.get('nickname').should.equal(data.nickname);
              p2.get('generalInfo').should.equal(data.generalInfo);
              done();
            });
        });
    });
  });

  it('Update without id', function(done) {
    Patient.forge(testPatient1)
      .save()
      .then(function(p1) {
        var data = {
          firstname: 'Mandy'
          , nickname: 'Man'
          , generalInfo: 'This is a test'
        };
        delIds.push(p1.id);
        patient.update(data, function(err) {
          if (err) return done();
          done(new Error('Update did not error out due to no id passed.'));
        });
      });
  });

  it('Update a non-existent attribute', function(done) {
    Patient.forge(testPatient3)
      .save()
      .then(function(p1) {
        var data = {
          id: p1.id
          , notHere: 1
        };
        delIds.push(p1.id);
        patient.update(data, function(err) {
          if (err) return done(err);
          Patient.forge({id: p1.id})
            .fetch()
            .then(function(p2) {
              if (p2 && p2.notHere) return done(new Error('Saved a non-existent attribute (somehow).'));
              // Note: if the non-existent attribute is not removed before the
              // database call, the process will hang and fail. If get here then success.
              done();
            });
        });
      });
  });

});

