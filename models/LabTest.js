/*
 * -------------------------------------------------------------------------------
 * LabTest.js
 *
 * The model for a lab test which is a specific test of a certain lab suite.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LabTest = {}
  , LabTests
  ;

/*
CREATE TABLE `labTest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(70) NOT NULL,
  `abbrev` varchar(70) DEFAULT NULL,
  `normal` varchar(50) DEFAULT NULL,
  `unit` varchar(10) DEFAULT NULL,
  `minRangeDecimal` decimal(7,3) DEFAULT NULL,
  `maxRangeDecimal` decimal(7,3) DEFAULT NULL,
  `minRangeInteger` int(11) DEFAULT NULL,
  `maxRangeInteger` int(11) DEFAULT NULL,
  `labSuite_id` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `abbrev` (`abbrev`),
  KEY `labSuite_id` (`labSuite_id`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `labTest_ibfk_1` FOREIGN KEY (`labSuite_id`) REFERENCES `labSuite` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTest_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTest_ibfk_3` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1
*/

LabTest = Bookshelf.Model.extend({
  tableName: 'labTest'

  , permittedAttributes: ['id', 'name', 'abbrev', 'normal', 'unit',
        'minRangeDecimal', 'maxRangeDecimal', 'minRangeInteger', 'maxRangeInteger',
        'labSuite_id', 'updatedBy', 'updatedAt', 'supervisor']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  //
  // Note: avoid circular references by using require() inline.
  // https://github.com/tgriesser/bookshelf/issues/105
  // --------------------------------------------------------

  , LabSuite: function() {
      return this.belongsTo(require('./LabSuite').LabSuite, 'labSuite_id');
    }

  , LabTestValue: function() {
      return this.hasMany(require('./LabTestValue').LabTestValue, 'labTest_id');
    }

  , LabTestResult: function() {
      return this.hasMany(require('./LabTestResult').LabTestResult, 'labTest_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

LabTests = Bookshelf.Collection.extend({
  model: LabTest
});

module.exports = {
  LabTest: LabTest
  , LabTests: LabTests
};

