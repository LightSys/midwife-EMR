/* 
 * -------------------------------------------------------------------------------
 * test.util.js
 *
 * Testing of the util.js module at the top level of the application (not the
 * utils.js in the test folder).
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
  , _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , util = require('../util')
  ;


describe('Util', function(done) {
  this.timeout(5000);

  describe('isValidDate', function(done) {
    it('should pass with a JS Date', function(done) {
      var pass
        ;
      pass = util.isValidDate(new Date());
      should(pass).equal(true);
      done();
    });

    it('should not pass with a non-Date object', function(done) {
      var pass
        ;
      pass = util.isValidDate({something: true});
      should(pass).equal(false);
      done();
    });

    it('should pass with a valid Moment object', function(done) {
      var pass
        ;
      pass = util.isValidDate(moment());
      should(pass).equal(true);
      done();
    });

    it('should not pass with an invalid Moment object', function(done) {
      var pass
        ;
      pass = util.isValidDate(moment.invalid());
      should(pass).equal(false);
      done();
    });

    it('should pass with a String that matches a passed format', function(done) {
      var pass
        ;
      pass = util.isValidDate('2014-03-11', 'YYYY-MM-DD');
      should(pass).equal(true);
      done();
    });

    it('should not pass with a String that does not match a passed format', function(done) {
      var pass
        ;
      pass = util.isValidDate('02-11-2013', 'YYYY-MM-DD');
      should(pass).equal(false);
      done();
    });

    it('should not pass with a String without a passed format', function(done) {
      var pass
        ;
      pass = util.isValidDate('02-11-2013');
      should(pass).equal(false);
      done();
    });

  });

  describe('validOrVoidDate', function(done) {
    it('should return the same Date object if one is passed', function(done) {
      var d = new Date();
      var result = util.validOrVoidDate(d);
      d.should.be.a.Date;
      done();
    });

    it('should return undefined if a string is passed', function(done) {
      var d = 'This is a test string';
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });

    it('should return undefined if a string that looks like a date is passed', function(done) {
      var d = 'Wed Sep 16 2015 21:27:17 GMT+0800 (PHT)';
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });

    it('should return undefined if a date string with zeroes is passed', function(done) {
      var d = '0000-00-00';
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });

    it('should return undefined if undefined is passed', function(done) {
      var d = void 0;
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });

    it('should return undefined if null is passed', function(done) {
      var d = null;
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });

    it('should return undefined if a valid Moment object is passed', function(done) {
      var d = moment();
      var result = util.validOrVoidDate(d);
      should.not.exist(result);
      done();
    });
  });

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
      var edd = moment().add(23, 'days')
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('36 5/7');
      done();
    });

    it('should handle edd in the future by 180 days', function(done) {
      var edd = moment().add(180, 'days')
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('14 2/7');
      done();
    });

    it('should handle edd in the past by 23 days', function(done) {
      var edd = moment().subtract(23, 'days')
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('43 2/7');
      done();
    });

    it('should handle edd in the past by 180 days', function(done) {
      var edd = moment().subtract(180, 'days')
        , result
        ;
      result = util.getGA(edd);
      result.should.equal('65 5/7');
      done();
    });

    it('should handle edd & rDate parameters', function(done) {
      var edd = moment().subtract(100, 'days')
        , rDate = moment(edd).subtract(23, 'days')
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('36 5/7');
      done();
    });

    it('should handle edd & rDate parameters with rDate greater than edd', function(done) {
      var edd = moment().subtract(100, 'days')
        , rDate = edd.clone().add(23, 'days')
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('43 2/7');
      done();
    });

    it('should handle date objects as parameters', function(done) {
      var edd = moment().subtract(100, 'days').toDate()
        , rDate = moment(edd).add(23, 'days').toDate()
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

    it('should handle a ref date before pregnancy started', function(done) {
      var edd = '2014-12-01'
        , rDate = '2014-01-03'
        , result
        ;
      result = util.getGA(edd, rDate);
      result.should.equal('0 0/7');
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

    it('should not change first parameter passed by reference as a moment instance', function(done) {
      var edd = moment().subtract(100, 'days')
        , rDate = edd.clone().add(23, 'days')
        , eddSecs = edd.unix()
        , result1
        , result2
        ;
      result1 = util.getGA(edd, rDate);
      should(edd.unix()).equal(eddSecs);
      result2 = util.getGA(edd, rDate);
      result1.should.equal(result2);
      done();
    });

    it('should not change second parameter passed by reference as a moment instance', function(done) {
      var edd = moment().subtract(100, 'days')
        , rDate = edd.clone().add(23, 'days')
        , rDateSecs = rDate.unix()
        , result1
        , result2
        ;
      result1 = util.getGA(edd, rDate);
      should(rDate.unix()).equal(rDateSecs);
      result2 = util.getGA(edd, rDate);
      result1.should.equal(result2);
      done();
    });

    it('should not change first parameter passed by reference as a Date instance', function(done) {
      var edd = new Date(2013, 10, 23)
        , rDate = new Date(2013, 11, 28)
        , eddSecs = edd.getTime()
        , result1
        , result2
        ;
      result1 = util.getGA(edd, rDate);
      should(edd.getTime()).equal(eddSecs);
      result2 = util.getGA(edd, rDate);
      result1.should.equal(result2);
      done();
    });

    it('should not change second parameter passed by reference as a Date instance', function(done) {
      var edd = new Date(2013, 10, 23)
        , rDate = new Date(2013, 11, 28)
        , rDateSecs = rDate.getTime()
        , result1
        , result2
        ;
      result1 = util.getGA(edd, rDate);
      should(rDate.getTime()).equal(rDateSecs);
      result2 = util.getGA(edd, rDate);
      result1.should.equal(result2);
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
      edd.should.be.a.String;
      /....-..-../.test(edd).should.be.true;
      moment(edd, 'YYYY-MM-DD').isValid().should.be.true;
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
      edd.should.be.a.String;
      /....-..-../.test(edd).should.be.true;
      moment(edd, 'YYYY-MM-DD').isValid().should.be.true;
      done();
    });

    it('if passed a String instance, should throw an error', function(done) {
      var lmp = '2014-11-23'
        , edd
        , isValid
        ;
      (function() {
        edd = util.calcEdd(lmp);
      }).should.throw();
      done();
    });

    it('should estimate based on historical lmp', function(done) {
      var lmp = moment().subtract(55, 'days')
        , edd
        , validEdd = moment(lmp)
        ;
      validEdd.add(280, 'days');
      edd = moment(util.calcEdd(lmp), 'YYYY-MM-DD');
      edd.year().should.equal(validEdd.year());
      edd.month().should.equal(validEdd.month());
      edd.day().should.equal(validEdd.day());
      done();
    });

    it('should estimate based on future lmp', function(done) {
      var lmp = moment().add(55, 'days')
        , edd
        , validEdd = moment(lmp)
        ;
      validEdd.add(280, 'days');
      edd = moment(util.calcEdd(lmp), 'YYYY-MM-DD');
      edd.year().should.equal(validEdd.year());
      edd.month().should.equal(validEdd.month());
      edd.day().should.equal(validEdd.day());
      done();
    });

    it('should return a string in YYYY-MM-DD format by default', function(done) {
      var lmp = moment('2000-01-01', 'YYYY-MM-DD')
        , edd
        ;
      edd = util.calcEdd(lmp);
      edd.should.be.a.String;
      /....-..-../.test(edd).should.be.true;
      edd.slice(0, 4).should.equal('2000');
      edd.slice(5, 7).should.equal('10');
      edd.slice(8, 10).should.equal('07');
      done();
    });

    it('should return a string in MM/DD/YYYY format if requested', function(done) {
      var lmp = moment('2000-01-01', 'YYYY-MM-DD')
        , edd
        ;
      edd = util.calcEdd(lmp, 'MM/DD/YYYY');
      edd.should.be.a.String;
      /..\/..\/..../.test(edd).should.be.true;
      edd.slice(0, 2).should.equal('10');
      edd.slice(3, 5).should.equal('07');
      edd.slice(6, 10).should.equal('2000');
      done();
    });

  });

  describe('addBlankSelectData', function(done) {
    var sel1
      ;

    beforeEach(function(done) {
      sel1 = [];
      sel1.push({selectKey: '?', label: 'Unknown', selected: true});
      sel1.push({selectKey: 'N', label: 'No', selected: false});
      sel1.push({selectKey: 'Y', label: 'Yes', selected: false});
      done();
    });

    it('length should be increased by one', function(done) {
      var origLen = sel1.length
        , newList
        ;
      util.addBlankSelectData(sel1);
      sel1.should.have.length(origLen + 1);
      done();
    });

    it('blank record should be first', function(done) {
      var newList
        ;
      util.addBlankSelectData(sel1);
      sel1[0].selectKey.should.have.length(0);
      sel1[0].label.should.have.length(0);
      sel1[0].selected.should.be.true;
      done();
    });

    it('blank record should be only one selected', function(done) {
      var newList
        ;
      util.addBlankSelectData(sel1);
      _.where(sel1, {selected: true}).should.have.length(1);
      done();
    });

    it('should only allow one blank record', function(done) {
      var newList1
        , newList2
        , origLen = sel1.length
        ;
      // TODO: acknowledge and address that fact that the passed list
      // is passed by reference and so the assignment here is a little
      // misleading. OR change to clone the list.
      util.addBlankSelectData(sel1);
      sel1.should.have.length(origLen + 1);
      util.addBlankSelectData(sel1);
      sel1.should.have.length(origLen + 1);
      done();
    });

  });

  describe('adjustSelectData()', function(done) {
    var sel1 = []
      , sel2 = []
      , sel3 = []
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
      sel3.push({selectKey: '', label: '', selected: false});
      sel3.push({selectKey: '?', label: 'Unknown', selected: false});
      sel3.push({selectKey: 'N', label: 'No', selected: true});
      sel3.push({selectKey: 'Y', label: 'Yes', selected: false});
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

    it('if not key passed, retains default', function(done) {
      var newSel3 = util.adjustSelectData(sel3, void(0))
        ;
      sel3[2].selected.should.be.true;
      newSel3[2].selected.should.be.true;
      done();
    });

  });

});




