/* 
 * -------------------------------------------------------------------------------
 * RiskCode.js
 *
 * The lookup for the various pregnancy risks.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , RiskCode = {}
  ;

/*
CREATE TABLE `riskCode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `riskType` varchar(20) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1
*/

RiskCode = Bookshelf.Model.extend({
  tableName: 'riskCode'

  , permittedAttributes: ['id', 'name', 'riskType', 'description']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , risk: function() {
      return this.belongsTo(require('./Risk').Risk, 'riskCode');
    }

});

RiskCodes = Bookshelf.Collection.extend({
  model: RiskCode
});

module.exports = {
  RiskCode: RiskCode
  , RiskCodes: RiskCodes
};



