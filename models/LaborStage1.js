/*
 * -------------------------------------------------------------------------------
 * LaborStage1.js
 *
 * The model for the laborStage1 table, which is a detail table of labor.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , LaborStage1 = {}
  , LaborsStage1
  ;

/*
CREATE TABLE `laborStage1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fullDialation` datetime NULL,
  `mobility` varchar(200) DEFAULT NULL,
  `durationLatent` int(11) DEFAULT NULL,
  `durationActive` int(11) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `laborStage1_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `laborStage1_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/


LaborStage1 = Bookshelf.Model.extend({
  tableName: 'laborStage1'

  , permittedAttributes: ['id', 'fullDialation', 'mobility', 'durationLatent',
      'durationActive', 'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

  , pregnancy: function() {
      return this.belongsTo(require('./Labor').Labor, 'labor_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

LaborStage1s = Bookshelf.Collection.extend({
  model: LaborStage1
});

module.exports = {
  LaborStage1: LaborStage1
  , LaborStage1s: LaborStage1s
};

