/* 
 * -------------------------------------------------------------------------------
 * MedicationType.js
 *
 * The model for types of medications, vitamins, iron, etc.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , MedicationType = {}
  ;

/*
CREATE TABLE `medicationType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  `sortOrder` tinyint(4) NOT NULL DEFAULT '0',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `medicationType_sortOrder_idx` (`sortOrder`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `medicationType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `medicationType_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1
*/

MedicationType = Bookshelf.Model.extend({
  tableName: 'medicationType'

  , permittedAttributes: ['id', 'name', 'description', 'updatedBy', 'updatedAt',
      'supervisor', 'sortOrder']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , medication: function() {
      return this.hasOne(require('./Medication').Medication, 'medicationType');
    }

});

MedicationTypes = Bookshelf.Collection.extend({
  model: MedicationType
});

module.exports = {
  MedicationType: MedicationType
  , MedicationTypes: MedicationTypes
};



