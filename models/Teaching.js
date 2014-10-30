/*
 * -------------------------------------------------------------------------------
 * Teaching.js
 *
 * The model for health teaching data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Referral = {}
  ;

/*
CREATE TABLE `healthTeaching` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `topic` varchar(50) NOT NULL,
  `teacher` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `teacher` (`teacher`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `healthTeaching_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `healthTeaching_ibfk_2` FOREIGN KEY (`teacher`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `healthTeaching_ibfk_3` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `healthTeaching_ibfk_4` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Teaching = Bookshelf.Model.extend({
  tableName: 'healthTeaching'

  , permittedAttributes: ['id', 'date', 'topic', 'teacher',
      'updatedBy', 'updatedAt', 'supervisor', 'pregnancy_id']

  , initialize: function() {
      this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Teachings = Bookshelf.Collection.extend({
  model: Teaching
});

module.exports = {
  Teaching: Teaching
  , Teachings: Teachings
};

