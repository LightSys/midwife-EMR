/*
 * -------------------------------------------------------------------------------
 * PregnancyHistory.js
 *
 * The model for historical pregnancy data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , PregnancyHistory = {}
  ;

/*
CREATE TABLE `pregnancyHistory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `month` varchar(2) DEFAULT NULL,
  `year` varchar(4) NOT NULL,
  `weeksGA` int(11) DEFAULT NULL,
  `sexOfBaby` char(1) DEFAULT NULL,
  `placeOfBirth` varchar(30) DEFAULT NULL,
  `attendant` varchar(30) DEFAULT NULL,
  `typeOfDelivery` varchar(30) DEFAULT NULL,
  `lengthOfLabor` tinyint(4) DEFAULT NULL,
  `birthWeight` decimal(2,2) DEFAULT NULL,
  `episTear` tinyint(1) DEFAULT NULL,
  `repaired` tinyint(1) DEFAULT NULL,
  `howLongBFed` varchar(20) DEFAULT NULL,
  `note` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `pregnancy_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `pregnancyHistory_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnancyHistory_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pregnancyHistory_ibfk_3` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1
*/

PregnancyHistory = Bookshelf.Model.extend({
  tableName: 'pregnancyHistory'

  , permittedAttributes: ['id', 'month', 'year', 'weeksGA', 'sexOfBaby',
    'placeOfBirth', 'attendant', 'typeOfDelivery', 'lengthOfLabor', 'birthWeight',
    'episTear', 'repaired', 'howLongBFed', 'note', 'updatedBy', 'updatedAt',
    'supervisor', 'pregnancy_id']

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

PregnancyHistories = Bookshelf.Collection.extend({
  model: PregnancyHistory
});

module.exports = {
  PregnancyHistory: PregnancyHistory
  , PregnancyHistories: PregnancyHistories
};

