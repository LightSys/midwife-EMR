/*
 * -------------------------------------------------------------------------------
 * MembranesResus.js
 *
 * The model for the membranesResus table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , MembranesResus = {}
  , MembranesResuses
  ;

/*
CREATE TABLE `membranesResus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ruptureDatetime` datetime DEFAULT NULL,
  `rupture` enum('AROM','SROM','Other') DEFAULT NULL,
  `ruptureComment` varchar(300) DEFAULT NULL,
  `amniotic` enum('Clear','Lt Stain','Mod Stain','Thick Stain','Other') DEFAULT NULL,
  `amnioticComment` varchar(300) DEFAULT NULL,
  `bulb` tinyint(4) NOT NULL DEFAULT '0',
  `machine` tinyint(4) NOT NULL DEFAULT '0',
  `freeFlowO2` tinyint(4) NOT NULL DEFAULT '0',
  `chestCompressions` tinyint(4) NOT NULL DEFAULT '0',
  `ppv` tinyint(4) NOT NULL DEFAULT '0',
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `baby_id` (`baby_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `membranesResus_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `membranesResus_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

MembranesResus = Bookshelf.Model.extend({
  tableName: 'membranesResus'

  , permittedAttributes: ['id', 'ruptureDatetime', 'rupture', 'ruptureComment',
    'amniotic', 'amnioticComment', 'bulb', 'machine', 'freeFlowO2',
    'chestCompressions', 'ppv', 'comments', 'updatedBy', 'updatedAt',
    'supervisor', 'baby_id']

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

  , baby: function() {
      return this.belongsTo(require('./Baby').Labor, 'baby_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

MembranesResuses = Bookshelf.Collection.extend({
  model: MembranesResus
});

module.exports = {
  MembranesResus: MembranesResus
  , MembranesResuses: MembranesResuses
};

