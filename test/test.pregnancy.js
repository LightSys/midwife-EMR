/*
 * -------------------------------------------------------------------------------
 * test.pregnancy.js
 *
 * BDD testing of the routes that manage pregnancies.
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
  , Pregnancy = require('../models/Pregnancy').Pregnancy
  , Pregnancies = require('../models/Pregnancy').Pregnancies
  , PrenatalExam = require('../models/PrenatalExam').PrenatalExam
  , PrenatalExams = require('../models/PrenatalExam').PrenatalExams
  , getRandom = function(limit) {return Math.round(Math.random() * limit);}
  ;

describe('Pregnancy', function(done) {
  this.timeout(8000);

  before(function(done) {
    utils.loginManyAsync(request, allUserNames, allUserAgents)
      .then(function(success) {
        utils.setSuperAsync(request, attendingWithSuper, function(err, success) {
          if (err) return done(err);
          if (! success) return done('setSuper() failed');
          done();
        });
      })
      .caught(function(e) {
        done(e);
      });
  });

  describe('can display the create pregnancy form', function(done) {
    it('admin should not', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      admin.attachCookies(req);
      req
        .expect(403, done);
    });

    it('guard should not', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      guard.attachCookies(req);
      req
        .expect(403, done);
    });

    it('clerk should', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      clerk.attachCookies(req);
      req
        .expect(200, done);
    });

    it('supervisor should', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      supervisor.attachCookies(req);
      req
        .expect(200, done);
    });

    it('attending should not without supervisor', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      attendingWithoutSuper.attachCookies(req);
      req
        .expect(302)
        .expect('location', '/setsuper', done);
    });

    it('attending should with supervisor', function(done) {
      var req = request.get('/pregnancy/new')
        ;
      attendingWithSuper.attachCookies(req);
      req.expect(200, done);
    });
  });

  describe('create new record', function(done) {
    it('pregnancy record with empty fields will not save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          //postData.dob = '1988-12-31';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(302, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('pregnancy record with patient dob but empty pregnancy fields will not save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          postData.dob = '1988-12-31';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(302, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('pregnancy record with proper fields will save', function(done) {
      var fldsCfg = {
          request: request
          , agent: supervisor
          , getPath: cfg.path.pregnancyNewForm
          , formName: 'pregnancyForm'
          , postPath: cfg.path.pregnancyCreate
        }
        ;
      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          _.each(flds, function(fld) {
            postData[fld] = '';
          });
          postData.dob = '1988-12-31';
          postData.firstname = 'Sally';
          postData.lastname = 'Tester';
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect(302, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

  });

  describe('can display the prenatal page', function(done) {
    var pregId
      ;
    before(function(done) {
      new Pregnancies().fetchOne().then(function(model) {
        pregId = model.get('id');
        done();
      });
    });

    it('admin should not', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalEdit.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      admin.attachCookies(req);
      req
        .expect(403, done);
    });

    it('guard should not', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalEdit.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      guard.attachCookies(req);
      req
        .expect(403, done);
    });

    it('attending should', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalEdit.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      attendingWithSuper.attachCookies(req);
      req
        .expect(200, done);
    });

    it('clerk should', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalEdit.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      clerk.attachCookies(req);
      req
        .expect(200, done);
    });

    it('supervisor should', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalEdit.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      supervisor.attachCookies(req);
      req
        .expect(200, done);
    });

  });

  describe('clerk restriction on prenatal exam fields', function(done) {
    var pregId
      , peId
      , pregId2
      , peId2
      ;
    before(function(done) {
      new Pregnancies().fetch().then(function(list) {
        var idx = getRandom(list.length)
          , idx2 = getRandom(list.length)
          ;
        pregId = list.get(idx).get('id');
        pregId2 = list.get(idx2).get('id');
        new PrenatalExam({'pregnancy_id': pregId})
          .setUpdatedBy(1)
          .setSupervisor(1)
          .save().then(function(m1) {
            peId = m1.get('id');
            new PrenatalExam({'pregnancy_id': pregId2})
              .setUpdatedBy(1)
              .setSupervisor(1)
              .save().then(function(m2) {
                peId2 = m2.get('id');
                done();
            });
        });
      });
    });

    it('clerk can display add form', function(done) {
      var reqUrl = cfg.path.pregnancyPrenatalExamAdd.replace(':id', pregId)
        , req = request.get(reqUrl)
        ;
      clerk.attachCookies(req);
      req
        .expect(200, done);
    });

    it('clerk can add exam with weight and BP fields', function(done) {
      var fldsCfg = {
          request: request
          , agent: clerk
          , getPath: cfg.path.pregnancyPrenatalExamAdd.replace(':id', pregId)
          , formName: 'prenatalAddExam'
          , postPath: cfg.path.pregnancyPrenatalExamAdd.replace(':id', pregId)
        }
        ;

      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          postData.pregnancy_id = pregId;
          postData.weight = 50;
          postData.systolic = 110;
          postData.diastolic = 60;
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect('location', cfg.path.pregnancyPrenatalEdit.replace(':id', pregId))
                .expect(302, done);
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('clerk can not save disallowed fields on exam add', function(done) {
      var fldsCfg = {
          request: request
          , agent: clerk
          , getPath: cfg.path.pregnancyPrenatalExamAdd.replace(':id', pregId)
          , formName: 'prenatalAddExam'
          , postPath: cfg.path.pregnancyPrenatalExamAdd.replace(':id', pregId)
        }
        , crazyWgt = Math.round(Math.random() * 500)
        , testFH = 28
        ;

      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          postData.pregnancy_id = pregId;
          postData.weight = crazyWgt;
          postData.fh = testFH;
          postData.fht = 155;
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect('location', cfg.path.pregnancyPrenatalEdit.replace(':id', pregId))
                .expect(302, function() {
                  // Now access the prenatal record to verify that the cr
                  // field was not actually set.
                  new PrenatalExam({pregnancy_id: pregId, weight: crazyWgt})
                    .fetch({require: true})
                    .then(function(model) {
                      model.get('pregnancy_id').should.equal(pregId);
                      model.get('weight').should.equal(crazyWgt);
                      testFH.should.not.equal(model.get('fh'));
                      done();
                    })
                    .caught(function(err) {
                      done(err);
                    });
                });
              })
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('clerk can display edit form', function(done) {
      var url = cfg.path.pregnancyPrenatalExamEdit
        , reqUrl = url.replace(':id', pregId).replace(':id2', peId)
        , req = request.get(reqUrl)
        ;
      clerk.attachCookies(req);
      req
        .expect(200, done);
    });

    it('clerk can update exam for bp and weight fields', function(done) {
      var getUrl = cfg.path.pregnancyPrenatalExamEdit
        , postUrl = cfg.path.pregnancyPrenatalExamEdit
        , fldsCfg = {
            request: request
            , agent: clerk
            , getPath: getUrl.replace(':id', pregId).replace(':id2', peId)
            , formName: 'prenatalEditExam'
            , postPath: postUrl.replace(':id', pregId).replace(':id2', peId)
          }
        , weight = Math.round(Math.random() * 100)
        , syst = Math.round(Math.random() * 200)
        , dias = Math.round(Math.random() * 100)
        ;

      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          postData.id = peId;
          postData.pregnancy_id = pregId;
          postData.weight = weight;
          postData.systolic = syst;
          postData.diastolic = dias;
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect('location', cfg.path.pregnancyPrenatalEdit.replace(':id', pregId))
                .expect(302, function() {
                  // Now access the prenatal record to verify that the
                  // fields were actually set.
                  new PrenatalExam({pregnancy_id: pregId, id: peId})
                    .fetch({require: true})
                    .then(function(model) {
                      model.get('pregnancy_id').should.equal(pregId);
                      model.get('weight').should.equal(weight);
                      model.get('systolic').should.equal(syst);
                      model.get('diastolic').should.equal(dias);
                      done();
                    })
                    .caught(function(err) {
                      done(err);
                    });
                });
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });

    });

    it('clerk cannot update exam for other fields', function(done) {
      var getUrl = cfg.path.pregnancyPrenatalExamEdit
        , postUrl = cfg.path.pregnancyPrenatalExamEdit
        , fldsCfg = {
            request: request
            , agent: clerk
            , getPath: getUrl.replace(':id', pregId2).replace(':id2', peId2)
            , formName: 'prenatalEditExam'
            , postPath: postUrl.replace(':id', pregId2).replace(':id2', peId2)
          }
        , cr = Math.round(Math.random() * 100)
        , fh = Math.round(Math.random() * 75)
        ;

      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          postData.id = peId2;
          postData.pregnancy_id = pregId2;
          postData.cr = cr;
          postData.fh = fh;
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect('location', cfg.path.pregnancyPrenatalEdit.replace(':id', pregId))
                .expect(302, function() {
                  // Now access the prenatal record to verify that the
                  // fields were not actually set.
                  new PrenatalExam({pregnancy_id: pregId2, id: peId2})
                    .fetch({require: true})
                    .then(function(model) {
                      model.get('pregnancy_id').should.equal(pregId2);
                      fh.should.not.equal(model.get('fh'));
                      done();
                    })
                    .caught(function(err) {
                      done(err);
                    });
                });
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });
    });

    it('clerk cannot delete prenatal records', function(done) {
      var getUrl = cfg.path.pregnancyPrenatalExamEdit
        , postUrl = cfg.path.pregnancyPrenatalExamDelete
        , fldsCfg = {
            request: request
            , agent: clerk
            , getPath: getUrl.replace(':id', pregId2).replace(':id2', peId2)
            , formName: 'prenatalEditExam'
            , postPath: postUrl.replace(':id', pregId2).replace(':id2', peId2)
          }
        ;

      utils.getFormFieldsAsync(fldsCfg.request, fldsCfg.agent,
        fldsCfg.getPath, fldsCfg.formName)
        .then(function(flds) {
          var postData = {}
            ;
          postData.id = peId2;
          postData.pregnancy_id = pregId2;
          return postData;
        })
        .then(function(postData) {
          fldsCfg = _.extend(fldsCfg, {postData: postData});
          utils.prepPostAsync(fldsCfg)
            .then(function(postInfo) {
              postInfo.postReq
                .send(postInfo.formData)
                .expect('location', cfg.path.pregnancyPrenatalEdit.replace(':id', pregId))
                .expect(403, done());
            })
            .caught(function(e) {
              done(e);
            });
        })
        .caught(function(e) {
          done(e);
        });

    });

  });
});



