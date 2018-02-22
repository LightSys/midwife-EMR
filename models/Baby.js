/*
 * -------------------------------------------------------------------------------
 * Baby.js
 *
 * The model for the baby table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Baby = {}
  , Babys
  ;

/*
CREATE TABLE `baby` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `birthNbr` int(11) NOT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `sex` enum('M','F') NOT NULL,
  `birthWeight` int(11) DEFAULT NULL,
  `bFedEstablished` datetime DEFAULT NULL,
  `nbsDate` datetime DEFAULT NULL,
  `nbsResult` varchar(50) DEFAULT NULL,
  `bcgDate` datetime DEFAULT NULL,
  `bulb` tinyint(1) DEFAULT NULL,
  `machine` tinyint(1) DEFAULT NULL,
  `freeFlowO2` tinyint(1) DEFAULT NULL,
  `chestCompressions` tinyint(1) DEFAULT NULL,
  `ppv` tinyint(1) DEFAULT NULL,
  `comments` varchar(500) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `labor_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `labor_id` (`labor_id`,`birthNbr`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `baby_ibfk_1` FOREIGN KEY (`labor_id`) REFERENCES `labor` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `baby_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1

*/

Baby = Bookshelf.Model.extend({
  tableName: 'baby'

  , permittedAttributes: ['id', 'birthNbr', 'lastname', 'firstname', 'middlename',
     'sex', 'birthWeight', 'bFedEstablished', 'nbsDate', 'nbsResult', 'bcgDate',
     'bulb', 'machine', 'freeFlowO2', 'chestCompressions', 'ppv',
     'comments', 'updatedBy', 'updatedAt', 'supervisor', 'labor_id']

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

  , apgar: function() {
      return this.hasMany(require('./Apgar').Apgar, 'labor_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Babys = Bookshelf.Collection.extend({
  model: Baby
});

module.exports = {
  Baby: Baby
  , Babys: Babys
};

