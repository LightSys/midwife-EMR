/*
 * -------------------------------------------------------------------------------
 * SelectData.js
 *
 * The model for drop down lists and such.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , val = require('validator')
  , Promise = require('bluebird')
  , _ = require('underscore')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , SelectData = {}
  ;

/*
CREATE TABLE `selectData` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `selectKey` varchar(30) NOT NULL,
  `label` varchar(150) NOT NULL,
  `selected` tinyint(1) NOT NULL DEFAULT '0',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`selectKey`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `selectData_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `selectData_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1
*/

SelectData = Bookshelf.Model.extend({
  tableName: 'selectData'

  , permittedAttributes: ['id', 'name', 'selectKey', 'label', 'selected',
      'updatedBy', 'updatedAt', 'supervisor']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically.
    // --------------------------------------------------------
  , noUpdatedAt: true

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------


}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

  /* --------------------------------------------------------
   * getSelect()
   *
   * Returns an array of objects representing the selection
   * specified by name. Returns an empty array if name does
   * not match anything.
   *
   * param       name - the name of the group of selections
   * return      a promise
   * -------------------------------------------------------- */
  getSelect: function(name) {
    return new Promise(function(resolve, reject) {
      var query = new SelectData().query()
        ;
      query.where('name', '=', name)
        .select()
        .then(function(records) {
          var recs = _.map(records, function(rec) {
              var r = _.pick(rec, 'selectKey', 'label', 'selected')
                ;
              r.selected = r.selected? true: false;
              return r;
            })
            ;
          resolve(recs);
        })
        .caught(function(err) {
          reject(err);
        });
    });
  }

});

SelectDatas = Bookshelf.Collection.extend({
  model: SelectData
});

module.exports = {
  SelectData: SelectData
  , SelectDatas: SelectDatas
};

