/*
 * -------------------------------------------------------------------------------
 * Labor.js
 *
 * The model for the labor table, which is a master table for labor.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Labor = {}
  , Labors
  ;

/*
CREATE TABLE `labor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admittanceDate` datetime NOT NULL,
  `startLaborDate` datetime NOT NULL,
  `dischargeDate` datetime DEFAULT NULL,
  `pos` varchar(10) DEFAULT NULL,
  `fh` int(11) DEFAULT NULL,
  `fht` varchar(50) DEFAULT NULL,
  `systolic` int(11) DEFAULT NULL,
  `diastolic` int(11) DEFAULT NULL,
  `cr` int(11) DEFAULT NULL,
  `temp` decimal(4,1) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pregnancy_id` (`pregnancy_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `labor_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `labor_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=latin1
*/


Labor = Bookshelf.Model.extend({
  tableName: 'labor'

  , permittedAttributes: ['id', 'admittanceDate', 'startLaborDate', 'dischargeDate',
      'pos', 'fh', 'fht', 'systolic', 'diastolic', 'cr', 'temp',
      'comments', 'updatedBy', 'updatedAt', 'supervisor', 'pregnancy_id']

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
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

  , baby: function() {
      return this.hasMany(require('./Baby').Baby, 'labor_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Labors = Bookshelf.Collection.extend({
  model: Labor
});

module.exports = {
  Labor: Labor
  , Labors: Labors
};

