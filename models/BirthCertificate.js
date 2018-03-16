/*
 * -------------------------------------------------------------------------------
 * BirthCertificate.js
 *
 * The model for the birthCertificate table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , BirthCertificate = {}
  , BirthCertificates
  ;

/*
CREATE TABLE `birthCertificate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `birthOrder` varchar(30) NOT NULL,
  `motherMaidenLastname` varchar(50) NOT NULL,
  `motherMiddlename` varchar(50) DEFAULT NULL,
  `motherFirstname` varchar(50) NOT NULL,
  `motherCitizenship` varchar(50) NOT NULL,
  `motherNumChildrenBornAlive` int(11) NOT NULL,
  `motherNumChildrenLiving` int(11) NOT NULL,
  `motherNumChildrenBornAliveNowDead` int(11) NOT NULL,
  `motherAddress` varchar(100) NOT NULL,
  `motherCity` varchar(50) NOT NULL,
  `motherProvince` varchar(50) NOT NULL,
  `motherCountry` varchar(50) NOT NULL,
  `fatherLastname` varchar(50) DEFAULT NULL,
  `fatherMiddlename` varchar(50) DEFAULT NULL,
  `fatherFirstname` varchar(50) DEFAULT NULL,
  `fatherCitizenship` varchar(50) DEFAULT NULL,
  `fatherReligion` varchar(50) DEFAULT NULL,
  `fatherOccupation` varchar(50) DEFAULT NULL,
  `fatherAgeAtBirth` int(11) DEFAULT NULL,
  `fatherAddress` varchar(100) DEFAULT NULL,
  `fatherCity` varchar(50) DEFAULT NULL,
  `fatherProvince` varchar(50) DEFAULT NULL,
  `fatherCountry` varchar(50) DEFAULT NULL,
  `dateOfMarriage` date DEFAULT NULL,
  `cityOfMarriage` varchar(50) DEFAULT NULL,
  `provinceOfMarriage` varchar(50) DEFAULT NULL,
  `countryOfMarriage` varchar(50) DEFAULT NULL,
  `attendantType` enum('Physician','Nurse','Midwife','Hilot','Other') NOT NULL,
  `attendantOther` varchar(20) DEFAULT NULL,
  `attendantFullname` varchar(70) NOT NULL,
  `attendantTitle` varchar(50) DEFAULT NULL,
  `attendantAddr1` varchar(50) DEFAULT NULL,
  `attendantAddr2` varchar(50) DEFAULT NULL,
  `informantFullname` varchar(70) NOT NULL,
  `informantRelationToChild` varchar(50) NOT NULL,
  `informantAddress` varchar(50) NOT NULL,
  `preparedByFullname` varchar(70) NOT NULL,
  `preparedByTitle` varchar(50) NOT NULL,
  `commTaxNumber` varchar(50) DEFAULT NULL,
  `commTaxDate` date DEFAULT NULL,
  `commTaxPlace` varchar(50) DEFAULT NULL,
  `receivedByName` varchar(100) DEFAULT NULL,
  `receivedByTitle` varchar(100) DEFAULT NULL,
  `affiateName` varchar(100) DEFAULT NULL,
  `affiateAddress` varchar(100) DEFAULT NULL,
  `affiateCitizenshipCountry` varchar(100) DEFAULT NULL,
  `affiateReason` varchar(100) DEFAULT NULL,
  `affiateIAm` varchar(100) DEFAULT NULL,
  `affiateCommTaxNumber` varchar(100) DEFAULT NULL,
  `affiateCommTaxDate` varchar(100) DEFAULT NULL,
  `affiateCommTaxPlace` varchar(100) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `baby_id` (`baby_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `birthCertificate_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `birthCertificate_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1
 */

BirthCertificate = Bookshelf.Model.extend({
  tableName: 'birthCertificate'

  , permittedAttributes: ['id', 'id', 'birthOrder', 'motherMaidenLastname',
    'motherMiddlename', 'motherFirstname', 'motherCitizenship',
    'motherNumChildrenBornAlive', 'motherNumChildrenLiving',
    'motherNumChildrenBornAliveNowDead', 'motherAddress', 'motherCity',
    'motherProvince', 'motherCountry', 'fatherLastname', 'fatherMiddlename',
    'fatherFirstname', 'fatherCitizenship', 'fatherReligion', 'fatherOccupation',
    'fatherAgeAtBirth', 'fatherAddress', 'fatherCity', 'fatherProvince',
    'fatherCountry', 'dateOfMarriage', 'cityOfMarriage', 'provinceOfMarriage',
    'countryOfMarriage', 'attendantType', 'attendantOther', 'attendantFullname',
    'attendantTitle', 'attendantAddr1', 'attendantAddr2', 'informantFullname',
    'informantRelationToChild', 'informantAddress', 'preparedByFullname',
    'preparedByTitle', 'commTaxNumber', 'commTaxDate', 'commTaxPlace',
    'receivedByName', 'receivedByTitle', 'affiateName', 'affiateAddress',
    'affiateCitizenshipCountry', 'affiateReason', 'affiateIAm',
    'affiateCommTaxNumber', 'affiateCommTaxDate', 'affiateCommTaxPlace',
    'comments', 'updatedBy', 'updatedAt', 'supervisor', 'baby_id']

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
      return this.belongsTo(require('./Baby').Labor, 'baby_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

BirthCertificates = Bookshelf.Collection.extend({
  model: BirthCertificate
});

module.exports = {
  BirthCertificate: BirthCertificate
  , BirthCertificates: BirthCertificates
};


