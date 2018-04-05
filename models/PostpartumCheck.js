/*
 * -------------------------------------------------------------------------------
 * PostpartumCheck.js
 *
 * The model for the contPostpartumCheck table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , PostpartumCheck = {}
  , PostpartumChecks
  ;

/*
CREATE TABLE `postpartumCheck` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `checkDatetime` datetime NOT NULL,
  `babyWeight` int(11) DEFAULT NULL,
  `babyTemp` decimal(4,1) DEFAULT NULL,
  `babyCR` int(11) DEFAULT NULL,
  `babyRR` int(11) DEFAULT NULL,
  `babyLungs` varchar(500) DEFAULT NULL,
  `babyColor` varchar(500) DEFAULT NULL,
  `babySkin` varchar(500) DEFAULT NULL,
  `babyCord` varchar(500) DEFAULT NULL,
  `babyUrine` varchar(100) DEFAULT NULL,
  `babyStool` varchar(100) DEFAULT NULL,
  `babySSInfection` varchar(500) DEFAULT NULL,
  `babyFeeding` varchar(500) DEFAULT NULL,
  `babyFeedingDaily` varchar(100) DEFAULT NULL,
  `motherTemp` decimal(4,1) DEFAULT NULL,
  `motherSystolic` int(11) DEFAULT NULL,
  `motherDiastolic` int(11) DEFAULT NULL,
  `motherCR` int(11) DEFAULT NULL,
  `motherBreasts` varchar(500) DEFAULT NULL,
  `motherFundus` varchar(500) DEFAULT NULL,
  `motherPerineum` varchar(500) DEFAULT NULL,
  `motherLochia` varchar(500) DEFAULT NULL,
  `motherUrine` varchar(500) DEFAULT NULL,
  `motherStool` varchar(500) DEFAULT NULL,
  `motherSSInfection` varchar(500) DEFAULT NULL,
  `motherFamilyPlanning` varchar(500) DEFAULT NULL,
  `birthCertReq` tinyint(1) DEFAULT '0',
  `hgbRequested` tinyint(1) DEFAULT '0',
  `hgbTestDate` date DEFAULT NULL,
  `hgbTestResult` varchar(100) DEFAULT NULL,
  `ironGiven` int(11) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `nextScheduledCheck` date DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `postpartumCheck_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `postpartumCheck_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
*/

PostpartumCheck = Bookshelf.Model.extend({
  tableName: 'postpartumCheck'

  , permittedAttributes: ['id', 'checkDatetime', 'babyWeight', 'babyTemp', 'babyCR',
    'babyRR', 'babyLungs', 'babyColor', 'babySkin', 'babyCord', 'babyUrine',
    'babyStool', 'babySSInfection', 'babyFeeding', 'babyFeedingDaily', 'motherTemp',
    'motherSystolic', 'motherDiastolic', 'motherCR', 'motherBreasts', 'motherFundus',
    'motherPerineum', 'motherLochia', 'motherUrine', 'motherStool',
    'motherSSInfection', 'motherFamilyPlanning', 'birthCertReq', 'hgbRequested',
    'hgbTestDate', 'hgbTestResult', 'ironGiven', 'comments', 'nextScheduledCheck',
    'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

PostpartumChecks = Bookshelf.Collection.extend({
  model: PostpartumCheck
});

module.exports = {
  PostpartumCheck: PostpartumCheck
  , PostpartumChecks: PostpartumChecks
};


