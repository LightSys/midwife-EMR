/* 
 * -------------------------------------------------------------------------------
 * CustomField.js
 *
 * The model for custom database fields associated with the pregnancy.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , CustomField
  , CustomFields
  ;

/*
CREATE TABLE `customField` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customFieldType_id` int(11) NOT NULL,
  `pregnancy_id` int(11) NOT NULL,
  `booleanVal` tinyint(1) DEFAULT NULL,
  `intVal` int(11) DEFAULT NULL,
  `decimalVal` decimal(10,5) DEFAULT NULL,
  `textVAl` text,
  `dateTimeVal` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customFieldType_id` (`customFieldType_id`,`pregnancy_id`),
  KEY `pregnancy_id` (`pregnancy_id`),
  CONSTRAINT `customField_ibfk_1` FOREIGN KEY (`pregnancy_id`) REFERENCES `pregnancy` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

CustomField = Bookshelf.Model.extend({
  tableName: 'customField'

  , permittedAttributes: ['id', 'customFieldType_id', 'pregnancy_id', 'booleanVal',
      'intVal', 'decimalVal', 'textVal', 'dateTimeVal']

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically and the updatedBy and
    // supervisor fields should not be required either.
    // --------------------------------------------------------
  , noLogging: true

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , customFieldType: function() {
      return this.hasOne(require('./CustomFieldType').CustomFieldType, 'customFieldType_id');
    }

});

CustomFields = Bookshelf.Collection.extend({
  model: CustomField
});

module.exports = {
  CustomField: CustomField
  , CustomFields: CustomFields
};



