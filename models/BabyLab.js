/*
 * -------------------------------------------------------------------------------
 * BabyLab.js
 *
 * The model for the babyLab table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BabyLab = {}
  , BabyLabs
  ;

/*
CREATE TABLE `babyLab` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `babyLabType` int(11) NOT NULL,
  `dateTime` datetime NOT NULL,
  `fld1Value` varchar(300) DEFAULT NULL,
  `fld2Value` varchar(300) DEFAULT NULL,
  `fld3Value` varchar(300) DEFAULT NULL,
  `fld4Value` varchar(300) DEFAULT NULL,
  `initials` varchar(50) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `baby_id` (`baby_id`),
  KEY `babyLabType` (`babyLabType`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `babyLab_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyLab_ibfk_2` FOREIGN KEY (`babyLabType`) REFERENCES `babyLabType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `babyLab_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

BabyLab = Bookshelf.Model.extend({
  tableName: 'babyLab'

  , permittedAttributes: ['id', 'babyLabType', 'dateTime', 'fld1Value',
    'fld2Value', 'fld3Value', 'fld4Value', 'initials', 'updatedBy',
    'updatedAt', 'supervisor', 'baby_id']

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

  , babyLabType: function() {
      return this.hasOne(require('./BabyLabType').BabyLabType, 'babyLabType');
    }

  , baby: function() {
      return this.hasOne(require('./Baby').Baby, 'baby_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BabyLabs = Bookshelf.Collection.extend({
  model: BabyLab
});

module.exports = {
  BabyLab: BabyLab
  , BabyLabs: BabyLabs
};


