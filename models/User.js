/*
 * -------------------------------------------------------------------------------
 * User.js
 *
 * The model for user data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , bcrypt = require('bcrypt')
  , Promise = require('bluebird')
  , _ = require('underscore')
  , val = require('validator')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , cfg = require('../config')
  , NodeCache = require('node-cache')
  , userIdMapCache = new NodeCache({stdTTL: cfg.cache.userTTL, checkperiod: Math.round(cfg.cache.userTTL/10)})
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , User = {}
  , permittedAttributes = ['id', 'username', 'firstname', 'lastname', 'password',
      'email', 'lang', 'status', 'note', 'updatedBy', 'updatedAt', 'supervisor']
  ;


var hashPassword = function(pw, cb) {
  //var start = moment();
  bcrypt.genSalt(10, function(err, salt) {
    bcrypt.hash(pw, salt, function(er2, hash) {
      //logError('Hash generation time: ' + moment().diff(start));
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
  }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
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

  , checkProfileFields: function(rec, checkPasswords, cb) {
      var result = {
        success: true
        , messages: []
      };
      // --------------------------------------------------------
      // Required fields.
      //
      // TODO: i18n these messages.
      // --------------------------------------------------------
      if (! val.isLength(rec.firstname, 1)) result.messages.push('First name must be specified.');
      if (! val.isLength(rec.lastname, 1)) result.messages.push('Last name must be specified.');
      if (checkPasswords) {
        if (! val.isLength(rec.password, 8)) result.messages.push('Password must be at least 8 characters long.');
        if (! val.equals(rec.password, rec.password2)) result.messages.push('Passwords do not match.');
      }

      // --------------------------------------------------------
      // Optional fields.
      // --------------------------------------------------------
      if (rec.email && rec.email.length > 0) {
        if (! val.isEmail(rec.email)) result.messages.push('Email must be valid.');
      }

      if (result.messages.length != 0) {
        result.success = false;
      }
      return cb(null, result);
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
      //
      // TODO: i18n these messages.
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

    /* --------------------------------------------------------
     * getUserIdMap()
     *
     * Returns a promise that returns a hash of users with
     * the keys being their user id as a string and the
     * value being an object with three fields: username,
     * firstname, and lastname.
     *
     * Note: if the application is run as a cluster, each
     * instance will retain it's own copy of the cache.
     *
     * return      a promise
     * -------------------------------------------------------- */
  , getUserIdMap: function() {
      return new Promise(function(resolve, reject) {
        var knex = Bookshelf.knex
          ;
        userIdMapCache.get('usermap', function(err, map) {
          if (err) return reject(err);
          if (map && _.size(map) > 0) {
            return resolve(map['usermap']);
          }

          logInfo('User.getUserIdMap() - Refreshing user id map cache.');
          knex('user')
            .orderBy('id', 'asc')
            .select(['id', 'username', 'firstname', 'lastname'])
            .then(function(list) {
              var map = {};
              _.each(list, function(user) {
                map[user.id] = user;
              });
              userIdMapCache.set('usermap', map);
              resolve(map);
            })
            .caught(function(err) {
              logError(err);
              reject(err);
            });
        });
      });
    }

    /* --------------------------------------------------------
     * getFieldById()
     *
     * Returns a promise that returns the specified field of
     * the user with the given  passed id. If the id or
     * the fld are not found, returns undefined.
     *
     * Fields available are dependent upon getUserIdMap().
     * Currently they are username, firstname, and lastname.
     *
     * param       id - the user id
     * param       fld - the field to retrieve
     * return      a promise
     * -------------------------------------------------------- */
  , getFieldById: function(id, fld) {
      return new Promise(function(resolve, reject) {
        User.getUserIdMap().then(function(map) {
          if (map[id][fld]) return resolve(map[id][fld]);
          reject('Not found.');
        })
        .caught(function(err) {
          reject(err);
        });
      });
    }

});

Users = Bookshelf.Collection.extend({
  model: User
});




module.exports = {
  User: User
  , Users: Users
};
