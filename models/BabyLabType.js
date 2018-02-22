/*
 * -------------------------------------------------------------------------------
 * BabyLabType.js
 *
 * The model for the babyLabType table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyLabType = {}
  , BabyLabTypes
  ;

/*
CREATE TABLE `babyLabType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `fld1Name` varchar(50) NOT NULL,
  `fld1Type` enum('String','Integer','Float','Bool') NOT NULL DEFAULT 'String',
  `fld2Name` varchar(50) DEFAULT NULL,
  `fld2Type` enum('String','Integer','Float','Bool') DEFAULT NULL,
  `fld3Name` varchar(50) DEFAULT NULL,
  `fld3Type` enum('String','Integer','Float','Bool') DEFAULT NULL,
  `fld4Name` varchar(50) DEFAULT NULL,
  `fld4Type` enum('String','Integer','Float','Bool') DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyLabType_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
*/

BabyLabType = Bookshelf.Model.extend({
  tableName: 'babyLabType'

  , permittedAttributes: ['id', 'name', 'description', 'fld1Name',
    'fld1Type', 'fld2Name', 'fld2Type', 'fld3Name', 'fld3Type',
    'fld4Name', 'fld4Type', 'updatedBy', 'updatedAt', 'supervisor']

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

  , babyLab: function() {
      return this.hasMany(require('./BabyLab').BabyLab, 'babyLabType');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyLabTypes = Bookshelf.Collection.extend({
  model: BabyLabType
});

module.exports = {
  BabyLabType: BabyLabType
  , BabyLabTypes: BabyLabTypes
};


