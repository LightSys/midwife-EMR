/*
 * -------------------------------------------------------------------------------
 * Membrane.js
 *
 * The model for the membrane table.
 *
 * Note that the membrane and baby tables are incorporating what was in the
 * membraneResus table, so that table will be retired.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Membrane = {}
  , Membranes
  ;

/*
CREATE TABLE `membrane` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ruptureDatetime` datetime DEFAULT NULL,
  `rupture` enum('AROM','SROM','Other') DEFAULT NULL,
  `ruptureComment` varchar(300) DEFAULT NULL,
  `amniotic` enum('Clear','Lt Stain','Mod Stain','Thick Stain','Other') DEFAULT NULL,
  `amnioticComment` varchar(300) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `membrane_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `membrane_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
 */

Membrane = Bookshelf.Model.extend({
  tableName: 'membrane'

  , permittedAttributes: ['id', 'ruptureDatetime', 'rupture', 'ruptureComment',
     'amniotic', 'amnioticComment', 'comments', 'updatedBy', 'updatedAt',
     'supervisor', 'labor_id']

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

Membranes = Bookshelf.Collection.extend({
  model: Membrane
});

module.exports = {
  Membrane: Membrane
  , Membranes: Membranes
};

