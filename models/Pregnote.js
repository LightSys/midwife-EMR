/*
 * -------------------------------------------------------------------------------
 * Pregnote.js
 *
 * The model for notes of various kinds related to a pregnancy.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Pregnote = {}
  ;

/*
CREATE TABLE `pregnote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pregnoteType` int(11) NOT NULL,
  `noteDate` date NOT NULL,
  `note` text,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `pregnoteType` (`pregnoteType`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `pregnote_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnote_ibfk_2` FOREIGN KEY (`pregnoteType`) REFERENCES `pregnoteType` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnote_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Pregnote = Bookshelf.Model.extend({
  tableName: 'pregnote'

  , permittedAttributes: ['id', 'pregnoteType', 'noteDate', 'note', 'updatedBy',
     'updatedAt', 'supervisor', 'pregnancy_id']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }
  , pregnoteType: function() {
      return this.belongsTo(require('./PregnoteType').PregnoteType, 'pregnoteType');
    }

});

Pregnotes = Bookshelf.Collection.extend({
  model: Pregnote
});

module.exports = {
  Pregnote: Pregnote
  , Pregnotes: Pregnotes
};



