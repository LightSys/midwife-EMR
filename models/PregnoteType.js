/*
 * -------------------------------------------------------------------------------
 * PregnoteType.js
 *
 * The model for types of notes relating to the pregnancy.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , PregnoteType = {}
  ;

/*
CREATE TABLE `pregnoteType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

PregnoteType = Bookshelf.Model.extend({
  tableName: 'pregnoteType'

  , permittedAttributes: ['id', 'name', 'description']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , pregnote: function() {
      return this.hasOne(require('./Pregnote').Pregnote, 'pregnoteType');
    }

});

PregnoteTypes = Bookshelf.Collection.extend({
  model: PregnoteType
});

module.exports = {
  PregnoteType: PregnoteType
  , PregnoteTypes: PregnoteTypes
};



