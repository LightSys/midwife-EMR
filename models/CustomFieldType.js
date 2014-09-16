/* 
 * -------------------------------------------------------------------------------
 * CustomFieldType.js
 *
 * The model for custom database field types associated with the pregnancy.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , CustomFieldType
  , CustomFieldTypes
  ;

/*
customFieldType | CREATE TABLE `customFieldType` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(30) DEFAULT NULL,
  `description` varchar(250) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `valueFieldName` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
*/

CustomFieldType = Bookshelf.Model.extend({
  tableName: 'customFieldType'

  , permittedAttributes: ['id', 'title', 'description', 'label', 'valueFieldName']

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically and the updatedBy and
    // supervisor fields should not be required either.
    // --------------------------------------------------------
  , noLogging: true

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , customField: function() {
      return this.hasMany(require('./CustomField').CustomField, 'customFieldType_id');
    }

});

CustomFieldTypes = Bookshelf.Collection.extend({
  model: CustomFieldType
});

module.exports = {
  CustomFieldType: CustomFieldType
  , CustomFieldTypes: CustomFieldTypes
};



