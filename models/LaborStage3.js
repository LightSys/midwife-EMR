/*
 * -------------------------------------------------------------------------------
 * LaborStage3.js
 *
 * The model for the laborStage3 table, which is a detail table of labor.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LaborStage3 = {}
  , LaborsStage3
  ;

/*
CREATE TABLE `laborStage3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `placentaDatetime` datetime DEFAULT NULL,
  `placentaDeliverySpontaneous` tinyint(1) DEFAULT NULL,
  `placentaDeliveryAMTSL` tinyint(1) DEFAULT NULL,
  `placentaDeliveryCCT` tinyint(1) DEFAULT NULL,
  `placentaDeliveryManual` tinyint(1) DEFAULT NULL,
  `maternalPosition` varchar(50) DEFAULT NULL,
  `txBloodLoss1` varchar(50) DEFAULT NULL,
  `txBloodLoss2` varchar(50) DEFAULT NULL,
  `txBloodLoss3` varchar(50) DEFAULT NULL,
  `txBloodLoss4` varchar(50) DEFAULT NULL,
  `txBloodLoss5` varchar(50) DEFAULT NULL,
  `placentaShape` varchar(50) DEFAULT NULL,
  `placentaInsertion` varchar(50) DEFAULT NULL,
  `placentaNumVessels` int(11) DEFAULT NULL,
  `schultzDuncan` enum('Schultz','Duncan') DEFAULT NULL,
  `cotyledons` varchar(200) DEFAULT NULL,
  `membranes` varchar(200) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `laborStage3_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `laborStage3_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1
*/

LaborStage3 = Bookshelf.Model.extend({
  tableName: 'laborStage3'

  , permittedAttributes: ['id', 'placentaDatetime', 'placentaDeliverySpontaneous',
      'placentaDeliveryAMTSL', 'placentaDeliveryCCT', 'placentaDeliveryManual',
      'maternalPosition', 'txBloodLoss1', 'txBloodLoss2', 'txBloodLoss3',
      'txBloodLoss4', 'txBloodLoss5', 'placentaShape', 'placentaInsertion',
      'placentaNumVessels', 'schultzDuncan', 'cotyledons', 'membranes',
      'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id' ]

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

LaborStage3s = Bookshelf.Collection.extend({
  model: LaborStage3
});

module.exports = {
  LaborStage3: LaborStage3
  , LaborStage3s: LaborStage3s
};
