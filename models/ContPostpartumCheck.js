/*
 * -------------------------------------------------------------------------------
 * ContPostpartumCheck.js
 *
 * The model for the contPostpartumCheck table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , ContPostpartumCheck = {}
  , ContPostpartumChecks
  ;

/*
CREATE TABLE `contPostpartumCheck` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `checkDatetime` datetime NOT NULL,
  `motherSystolic` int(11) DEFAULT NULL,
  `motherDiastolic` int(11) DEFAULT NULL,
  `motherCR` int(11) DEFAULT NULL,
  `motherTemp` decimal(4,1) DEFAULT NULL,
  `motherFundus` varchar(200) DEFAULT NULL,
  `motherEBL` int(11) DEFAULT NULL,
  `babyBFed` varchar(200) DEFAULT NULL,
  `babyTemp` decimal(4,1) DEFAULT NULL,
  `babyRR` int(11) DEFAULT NULL,
  `babyCR` int(11) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `contPostpartumCheck_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `contPostpartumCheck_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1
*/

ContPostpartumCheck = Bookshelf.Model.extend({
  tableName: 'contPostpartumCheck'

  , permittedAttributes: ['id', 'checkDatetime', 'motherSystolic', 'motherDiastolic',
      'motherCR', 'motherTemp', 'motherFundus', 'motherEBL', 'babyBFed', 'babyTemp',
      'babyRR', 'babyCR', 'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

ContPostpartumChecks = Bookshelf.Collection.extend({
  model: ContPostpartumCheck
});

module.exports = {
  ContPostpartumCheck: ContPostpartumCheck
  , ContPostpartumChecks: ContPostpartumChecks
};

