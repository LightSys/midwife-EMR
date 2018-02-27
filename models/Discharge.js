/*
 * -------------------------------------------------------------------------------
 * Discharge.js
 *
 * The model for the discharge table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Discharge = {}
  , Discharges
  ;

/*
CREATE TABLE `discharge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dateTime` datetime DEFAULT NULL,
  `motherSystolic` int(11) DEFAULT NULL,
  `motherDiastolic` int(11) DEFAULT NULL,
  `motherTemp` float DEFAULT NULL,
  `motherCR` int(11) DEFAULT NULL,
  `babyRR` int(11) DEFAULT NULL,
  `babyTemp` float DEFAULT NULL,
  `babyCR` int(11) DEFAULT NULL,
  `ppInstructionsSchedule` tinyint(1) DEFAULT '0',
  `birthCertWorksheet` tinyint(1) DEFAULT '0',
  `birthRecorded` tinyint(1) DEFAULT '0',
  `chartsComplete` tinyint(1) DEFAULT '0',
  `logsComplete` tinyint(1) DEFAULT '0',
  `billPaid` tinyint(1) DEFAULT '0',
  `nbs` enum('Waived','Scheduled') DEFAULT NULL,
  `immunizationReferral` tinyint(1) DEFAULT '0',
  `breastFeedingEstablished` tinyint(1) DEFAULT '0',
  `newbornBath` tinyint(1) DEFAULT '0',
  `fundusFirmBleedingCtld` tinyint(1) DEFAULT '0',
  `motherAteDrank` tinyint(1) DEFAULT '0',
  `motherUrinated` tinyint(1) DEFAULT '0',
  `placentaGone` tinyint(1) DEFAULT '0',
  `prayer` tinyint(1) DEFAULT '0',
  `bible` tinyint(1) DEFAULT '0',
  `initials` varchar(50) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `discharge_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `discharge_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

Discharge = Bookshelf.Model.extend({
  tableName: 'discharge'

  , permittedAttributes: ['id', 'dateTime', 'motherSystolic', 'motherDiastolic',
    'motherTemp', 'motherCR', 'babyRR', 'babyTemp', 'babyCR', 'ppInstructionsSchedule',
    'birthCertWorksheet', 'birthRecorded', 'chartsComplete', 'logsComplete', 'billPaid',
    'nbs', 'immunizationReferral', 'breastFeedingEstablished', 'newbornBath',
    'fundusFirmBleedingCtld', 'motherAteDrank', 'motherUrinated', 'placentaGone',
    'prayer', 'bible', 'initials', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

  , labor: function() {
      return this.belongsTo(require('./Labor').Labor, 'labor_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Discharges = Bookshelf.Collection.extend({
  model: Discharge
});

module.exports = {
  Discharge: Discharge
  , Discharges: Discharges
};


