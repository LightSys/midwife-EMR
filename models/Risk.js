/* 
 * -------------------------------------------------------------------------------
 * Risk.js
 *
 * The model for pregnancy risks.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Risk = {}
  ;

/*
CREATE TABLE `risk` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pregnancy_id` int(11) NOT NULL,
  `riskCode` int(11) NOT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pregnancy_id` (`pregnancy_id`,`riskCode`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  KEY `riskCode` (`riskCode`),
  CONSTRAINT `risk_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `risk_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `risk_ibfk_3` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `risk_ibfk_4` FOREIGN KEY (`riskCode`) REFERENCES `riskCode` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

Risk = Bookshelf.Model.extend({
  tableName: 'risk'

  , permittedAttributes: ['id', 'pregnancy_id', 'riskCode',
      'updatedBy', 'updatedAt', 'supervisor', 'pregnancy_id']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

  , riskCode: function() {
      return this.hasOne(require('./RiskCode').RiskCode, 'riskCode');
    }

});

Risks = Bookshelf.Collection.extend({
  model: Risk
});

module.exports = {
  Risk: Risk
  , Risks: Risks
};



