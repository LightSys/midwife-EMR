/*
 * -------------------------------------------------------------------------------
 * LabTestValue.js
 *
 * The model for a lab test value which is acceptable for a specific lab test.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LabTestValue = {}
  , LabTestValues
  ;

/*
CREATE TABLE `labTestValue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(50) NOT NULL,
  `labTest_id` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labTest_id` (`labTest_id`,`value`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `labTestValue_ibfk_1` FOREIGN KEY (`labTest_id`) REFERENCES `labTest` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTestValue_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labTestValue_ibfk_3` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=latin1
*/

LabTestValue = Bookshelf.Model.extend({
  tableName: 'labTestValue'

  , permittedAttributes: ['id', 'value', 'labTest_id',
             'updatedBy', 'updatedAt', 'supervisor']

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

  , LabTest: function() {
      return this.belongsTo(require('./LabTest').LabTest, 'labTest_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

LabTestValues = Bookshelf.Collection.extend({
  model: LabTestValue
});

module.exports = {
  LabTestValue: LabTestValue
  , LabTestValues: LabTestValues
};

