/*
 * -------------------------------------------------------------------------------
 * Apgar.js
 *
 * The model for the apgar table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Apgar = {}
  , Apgars
  ;

/*
CREATE TABLE `apgar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `minute` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `baby_id` (`baby_id`,`minute`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `apgar_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `apgar_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Apgar = Bookshelf.Model.extend({
  tableName: 'apgar'

  , permittedAttributes: ['id', 'minute', 'score', 'updatedBy', 'updatedAt', 'supervisor', 'baby_id']

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
      return this.belongsTo(require('./Baby').Baby, 'baby_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Apgars = Bookshelf.Collection.extend({
  model: Apgar
});

module.exports = {
  Apgar: Apgar
  , Apgars: Apgars
};

