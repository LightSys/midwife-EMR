/* 
 * -------------------------------------------------------------------------------
 * test.util.js
 *
 * Testing of the util.js module at the top level of the application (not the
 * utils.js in the test folder).
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
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , util = require('../util')
  ;


describe('Util', function(done) {
  this.timeout(5000);

  describe('getGA', function(done) {
    it('should throw exception if called with no parameters', function(done) {
      (function() {
        util.getGA();
      }).should.throw();
      done();
    });

    it('should handle calculation with edd set to today', function(done) {
      var edd = moment()
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('40 0/7');
      done();
    });

    it('should handle edd in the future by 23 days', function(done) {
      var edd = moment().add('days', 23)
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('36 5/7');
      done();
    });

    it('should handle edd in the future by 180 days', function(done) {
      var edd = moment().add('days', 180)
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('14 2/7');
      done();
    });

    it('should handle edd in the past by 23 days', function(done) {
      var edd = moment().subtract('days', 23)
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('43 2/7');
      done();
    });

    it('should handle edd in the past by 180 days', function(done) {
      var edd = moment().subtract('days', 180)
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('65 5/7');
      done();
    });

    it('should handle edd & rDate parameters', function(done) {
      var edd = moment().subtract('days', 100)
        , rDate = moment(edd).subtract('days', 23)
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('36 5/7');
      done();
    });

    it('should handle edd & rDate parameters with rDate greater than edd', function(done) {
      var edd = moment().subtract('days', 100)
        , rDate = edd.clone().add('days', 23)
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('43 2/7');
      done();
    });

    it('should handle date objects as parameters', function(done) {
      var edd = moment().subtract('days', 100).toDate()
        , rDate = moment(edd).add('days', 23).toDate()
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('43 2/7');
      done();
    });

    it('should handle strings as parameters in YYYY-MM-DD format', function(done) {
      var edd = '2013-10-01'
        , rDate = '2013-07-13'
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('28 4/7');
      done();
    });

    it('should return empty string if first param is not date-like', function(done) {
      var edd = 'something else'
        , rDate = new Date()
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.have.length(0);
      result.should.equal('');
      done();
    });

    it('should return empty string if second param is not date-like', function(done) {
      var edd = '2013-10-01'
        , rDate = 'bad input'
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.have.length(0);
      result.should.equal('');
      done();
    });

  });

  describe('calcEdd', function(done) {
    it('should throw an exception if called with no parameters', function(done) {
      (function() {
        util.calcEdd();
      }).should.throw();
      done();
    });

    it('should throw an exception if called with a param that is not Date-like', function(done) {
      var lmp = 'Somewhere over the rainbow ...'
        ;
      (function() {
        util.calcEdd(lmp);
      }).should.throw();
      done();
    });

    it('if passed a Moment instance, should return a String', function(done) {
      var lmp = moment()
        , edd
        , isValid
        ;
      edd = util.calcEdd(lmp);
      if (! edd) return done(new Error('Result was undefined'));
      moment.isMoment(edd).should.be.false;
      moment(edd).isValid().should.be.true;
      edd.should.be.a.String;
      /....-..-../.test(edd).should.be.true;
      done();
    });

    it('if passed a Date instance, should return a String', function(done) {
      var lmp = new Date()
        , edd
        , isValid
        ;
      edd = util.calcEdd(lmp);
      if (! edd) return done(new Error('Result was undefined'));
      moment.isMoment(edd).should.be.false;
      moment(edd).isValid().should.be.true;
      edd.should.be.a.String;
      /....-..-../.test(edd).should.be.true;
      done();
    });

    it('should estimate based on historical lmp', function(done) {
      var lmp = moment().subtract('days', 55)
        , edd
        , validEdd = moment(lmp)
        ;
      validEdd.add('years', 1).subtract('months', 3).add('days', 7);
      edd = moment(util.calcEdd(lmp));
      edd.year().should.equal(validEdd.year());
      edd.month().should.equal(validEdd.month());
      edd.day().should.equal(validEdd.day());
      done();
    });

    it('should estimate based on future lmp', function(done) {
      var lmp = moment().add('days', 55)
        , edd
        , validEdd = moment(lmp)
        ;
      validEdd.add('years', 1).subtract('months', 3).add('days', 7);
      edd = moment(util.calcEdd(lmp));
      edd.year().should.equal(validEdd.year());
      edd.month().should.equal(validEdd.month());
      edd.day().should.equal(validEdd.day());
      done();
    });
  });

  describe('adjustSelectData()', function(done) {
    var sel1 = []
      , sel2 = []
      ;

    before(function(done) {
      sel1.push({selectKey: '', label: '', selected: true});
      sel1.push({selectKey: '?', label: 'Unknown', selected: false});
      sel1.push({selectKey: 'N', label: 'No', selected: false});
      sel1.push({selectKey: 'Y', label: 'Yes', selected: false});
      sel2.push({selectKey: '', label: '', selected: true});
      sel2.push({selectKey: '?', label: 'Unknown', selected: false});
      sel2.push({selectKey: 'N', label: 'No', selected: false});
      sel2.push({selectKey: 'Y', label: 'Yes', selected: false});
      done();
    });

    it('adjust selection by key', function(done) {
      var newSel1 = util.adjustSelectData(sel1, 'N')
        ;
      newSel1[0].selected.should.be.false;
      newSel1[2].selected.should.be.true;
      done();
    });

    it('adjust two selections independently', function(done) {
      var newSel1 = util.adjustSelectData(sel1, 'N')
        , newSel2 = util.adjustSelectData(sel1, 'Y')
        ;
      newSel1[0].selected.should.be.false;
      newSel1[2].selected.should.be.true;
      newSel2[0].selected.should.be.false;
      newSel2[3].selected.should.be.true;
      done();
    });
  });
});




