/*
 * -------------------------------------------------------------------------------
 * Role.js
 *
 * The model for role data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , bcrypt = require('bcrypt')
  , val = require('validator')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , User = {}
  , permittedAttributes =['id', 'name','description', 'updatedBy', 'updatedAt', 'supervisor']
  ;


Role = Bookshelf.Model.extend({
  // --------------------------------------------------------
  // Instance properties.
  // --------------------------------------------------------
  tableName: 'role'

  , permittedAttributes: permittedAttributes
  , initialize: function() {
    this.on('saving', this.saving, this);
  }

  , saving: function() {
    console.log('saving');
  }



  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , users: function() {
    return this.belongsToMany(User, 'user_role', 'role_id', 'user_id');
  }


}, {
  // --------------------------------------------------------
  // Class properties.
  // --------------------------------------------------------

  checkFields: function(rec, isAdd, cb) {
    var result = {
      success: true
      , messages: []
    };

    // --------------------------------------------------------
    // Required fields.
    // --------------------------------------------------------
    if (! val.isLength(rec.name, 1)) result.messages.push('Role name must be provided.');
    if (! val.isLength(rec.description, 1)) result.messages.push('Role description must be provided.');

    if (result.messages.length != 0) {
      result.success = false;
    }

    // --------------------------------------------------------
    // Check if this role is already taken if this is a
    // new record.
    // --------------------------------------------------------
    if (isAdd) {
      this.forge({name: rec.name})
        .fetch()
        .then(function(found) {
          if (found) {
            result.success = false;
            result.messages.push('The role name is already taken.');
          }
          return cb(null, result);
        });
    } else {
      return cb(null, result);
    }
  }



});


Roles = Bookshelf.Collection.extend({
  model: Role
});




module.exports = {
  Role: Role
  , Roles: Roles
};
