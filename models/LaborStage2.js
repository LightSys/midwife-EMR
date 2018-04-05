/*
 * -------------------------------------------------------------------------------
 * LaborStage2.js
 *
 * The model for the laborStage2 table, which is a detail table of labor.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LaborStage2 = {}
  , LaborsStage2
  ;

/*
CREATE TABLE `laborStage2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `birthDatetime` datetime DEFAULT NULL,
  `birthType` varchar(50) DEFAULT NULL,
  `birthPosition` varchar(100) DEFAULT NULL,
  `durationPushing` int(11) DEFAULT NULL,
  `birthPresentation` varchar(100) DEFAULT NULL,
  `terminalMec` tinyint(1) DEFAULT NULL,
  `cordWrapType` varchar(50) DEFAULT NULL,
  `deliveryType` varchar(100) DEFAULT NULL,
  `shoulderDystocia` tinyint(1) DEFAULT NULL,
  `shoulderDystociaMinutes` int(11) DEFAULT NULL,
  `laceration` tinyint(1) DEFAULT NULL,
  `episiotomy` tinyint(1) DEFAULT NULL,
  `repair` tinyint(1) DEFAULT NULL,
  `degree` varchar(50) DEFAULT NULL,
  `lacerationRepairedBy` varchar(100) DEFAULT NULL,
  `birthEBL` int(11) DEFAULT NULL,
  `meconium` varchar(50) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `laborStage2_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `laborStage2_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=latin1

*/


LaborStage2 = Bookshelf.Model.extend({
  tableName: 'laborStage2'

  , permittedAttributes: ['id', 'birthDatetime', 'birthType', 'birthPosition',
      'durationPushing', 'birthPresentation', 'terminalMec', 'cordWrapType',
      'deliveryType', 'shoulderDystocia', 'shoulderDystociaMinutes', 'laceration',
      'episiotomy', 'repair', 'degree', 'lacerationRepairedBy', 'birthEBL',
      'meconium', 'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

LaborStage2s = Bookshelf.Collection.extend({
  model: LaborStage2
});

module.exports = {
  LaborStage2: LaborStage2
  , LaborStage2s: LaborStage2s
};

