/* 
 * -------------------------------------------------------------------------------
 * Vaccine.js
 *
 * The look up table for vaccines.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Vaccine = {}
  ;

/*
CREATE TABLE `vaccines` (
  `name` varchar(255) DEFAULT NULL,
  `dosage` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO vaccines (name, dosage) VALUES('Tetanus Toxoid', NULL);

*/


Vaccine = Bookshelf.Model.extend({
  tableName: 'vaccines'

  , permittedAttributes: ['name','dosage','id','createdAt','updatedAt']

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
  , vaccinations: function() {
      return this.belongsTo(Vaccination);
    }
});

Vaccines = Bookshelf.Collection.extend({
  model: Vaccine
});

module.exports = {
  Vaccine: Vaccine
  , Vaccines: Vaccines
};


