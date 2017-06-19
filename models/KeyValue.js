/* 
 * -------------------------------------------------------------------------------
 * KeyValue.js
 *
 * The model for the key/val store used for configuration settings.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , KeyValue = {}
  ;

/*
CREATE TABLE `keyValue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kvKey` varchar(50) NOT NULL,
  `kvValue` varchar(200) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `valueType` enum('text','list','integer','decimal','date','boolean') NOT NULL,
  `acceptableValues` varchar(500) DEFAULT NULL,
  `systemOnly` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `kvKey` (`kvKey`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1
*/

KeyValue = Bookshelf.Model.extend({
  tableName: 'keyValue'

    // We severely restrict what is allowed at the ORM level in order to
    // prevent accidentally inserting/updating records inappropriately.
    // Records are not meant to be inserted or deleted by the application
    // itself, nor are most of the fields meant to be updated except to
    // store installation specific values for the established keys.
  , permittedAttributes: ['kvValue']

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically and the updatedBy and
    // supervisor fields should not be required either.
    // --------------------------------------------------------
  , noLogging: true

});

KeyValues = Bookshelf.Collection.extend({
  model: KeyValue
});

module.exports = {
  KeyValue: KeyValue
  , KeyValues: KeyValues
};



