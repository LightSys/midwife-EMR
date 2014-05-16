/*
 * -------------------------------------------------------------------------------
 * LabTestResult.js
 *
 * The results of a specific lab test for a specific pregnancy on a specific date.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LabTestResult = {}
  , LabTestResults
  ;

/*
CREATE TABLE `labTestResult` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `testDate` date NOT NULL,
  `result` varchar(100) NOT NULL,
  `result2` varchar(100) DEFAULT NULL,
  `warn` tinyint(1) DEFAULT NULL,
  `labTest_id` int(11) NOT NULL,
  `pregnancy_id` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `labTest_id` (`labTest_id`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `labTestResult_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTestResult_ibfk_2` FOREIGN KEY (`labTest_id`) REFERENCES `labTest` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTestResult_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTestResult_ibfk_4` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

LabTestResult = Bookshelf.Model.extend({
  tableName: 'labTestResult'

  , permittedAttributes: ['id', 'testDate', 'result', 'result2', 'warn',
        'labTest_id', 'pregnancy_id', 'updatedBy', 'updatedAt', 'supervisor']

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

  , Pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

  , LabTest: function() {
      return this.belongsTo(require('./LabTest').LabTest, 'labTest_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

LabTestResults = Bookshelf.Collection.extend({
  model: LabTestResult
});

module.exports = {
  LabTestResult: LabTestResult
  , LabTestResults: LabTestResults
};

