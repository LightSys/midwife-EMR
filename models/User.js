/*
 * -------------------------------------------------------------------------------
 * User.js
 *
 * The model for user data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , bcrypt = require('bcrypt')
  , _ = require('underscore')
  , val = require('validator')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , User = {}
  , permittedAttributes = ['id', 'username', 'firstname', 'lastname', 'password',
      'email', 'lang', 'status', 'note', 'updatedBy', 'updatedAt', 'supervisor']
  ;


var hashPassword = function(pw, cb) {
  //var start = moment();
  bcrypt.genSalt(10, function(err, salt) {
    bcrypt.hash(pw, salt, function(er2, hash) {
      //console.error('Hash generation time: ' + moment().diff(start));
      return cb(null, hash);
    });
  });
};

var checkPassword = function(pw, hash, cb) {
  bcrypt.compare(pw, hash, function(err, same) {
    if (err) return cb(err);
    return cb(null, same);
  });
};

User = Bookshelf.Model.extend({
  // --------------------------------------------------------
  // Instance properties.
  // --------------------------------------------------------
  tableName: 'user'

  , permittedAttributes: permittedAttributes
  , initialize: function() {
    this.on('saving', this.saving, this);
    this.on('created', this.created, this);
    this.on('updated', this.updated, this);
    this.on('destroyed', this.destroyed, this);
  }

  , defaults: {
    // Set the updatedAt field.
    //'updatedAt': moment().format('YYYY-MM-DD HH:mm:ss')
  }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
  }

  , created: function(model) {
      // Log the insert into the appropriate log table.
      Bookshelf.Model.prototype.logInsert.apply(this, [model, Bookshelf.knex]);
  }

  , updated: function(model) {
      // Log the insert into the appropriate log table.
      Bookshelf.Model.prototype.logUpdate.apply(this, [model, Bookshelf.knex]);
  }

  , destroyed: function(model) {
      // Log the insert into the appropriate log table.
      Bookshelf.Model.prototype.logDelete.apply(this, [model, Bookshelf.knex]);
  }

  , logDetach: function(deletions) {
      // Note: changes to the user_role table are not yet saved to the
      // user_roleLog table.
      //console.log('User.logDetach() for user id: ' + this.get('id'));
      //console.dir(deletions);
  }

  , logAttach: function(additions) {
      // Note: changes to the user_role table are not yet saved to the
      // user_roleLog table.
      //console.log('User.logAttach() for user id: ' + this.get('id'));
      //console.dir(additions);
  }

  , checkPassword: function(pw, cb) {
      this.fetch()
        .then(function(rec) {
          checkPassword(pw, rec.get('password'), function(err, same) {
            if (err) return cb(err);
            return cb(null, same);
          });
        });
  }

  , hashPassword: function(pw, cb) {
      var self = this;
      hashPassword(pw, function(err, hash) {
        if (err) return cb(err);
        self.set('password', hash);
        return cb(null, true);
      });
  }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , roles: function() {
    return this.belongsToMany(Role, 'user_role', 'user_id', 'role_id');
  }

}, {

  // --------------------------------------------------------
  // Class properties.
  // --------------------------------------------------------
  findById: function(id, cb) {
    this.forge({id: id})
      .fetch({withRelated: ['roles']})
      .then(function(u) {
        if (! u) return cb(new Error('User id ' + id + ' not found.'));
        return cb(null, u);
      });
  }

  , findByUsername: function(username, cb) {
      this.forge({username: username})
        .fetch({withRelated: ['roles']})
        .then(function(u) {
          if (! u) return cb(new Error('User ' + username + ' does not exist.'));
          return cb(null, u);
        });
  }

    /* --------------------------------------------------------
     * checkFields()
     *
     * Very basic validity checks. Allows not checking the
     * passwords for updates where the password is not being
     * updated (supposedly).
     *
     * param
     * return
     * -------------------------------------------------------- */
  , checkFields: function(rec, isAdd, checkPasswords, cb) {
      var result = {
        success: true
        , messages: []
      };
      // --------------------------------------------------------
      // Required fields.
      // --------------------------------------------------------
      if (! val.isLength(rec.username, 3)) result.messages.push('Username must be at least 3 characters long.');
      if (! val.isLength(rec.firstname, 1)) result.messages.push('First name must be specified.');
      if (! val.isLength(rec.lastname, 1)) result.messages.push('Last name must be specified.');
      if (checkPasswords) {
        if (! val.isLength(rec.password, 8)) result.messages.push('Password must be at least 8 characters long.');
        if (! val.equals(rec.password, rec.password2)) result.messages.push('Passwords do not match.');
      }
      if (! val.isIn(rec.status, ['0','1'])) result.messages.push('Unacceptable status - 0 or 1 required.');

      // --------------------------------------------------------
      // Optional fields.
      // --------------------------------------------------------
      if (rec.email.length > 0) {
        if (! val.isEmail(rec.email)) result.messages.push('Email must be valid.');
      }

      if (result.messages.length != 0) {
        result.success = false;
      }

      // --------------------------------------------------------
      // Check if this username is already taken if this is a
      // new record.
      // --------------------------------------------------------
      if (isAdd) {
        this.forge({username: rec.username})
          .fetch()
          .then(function(found) {
            if (found) {
              result.success = false;
              result.messages.push('The username is already taken.');
            }
            return cb(null, result);
          });
      } else {
        return cb(null, result);
      }
  }

});

Users = Bookshelf.Collection.extend({
  model: User
});




module.exports = {
  User: User
  , Users: Users
};
