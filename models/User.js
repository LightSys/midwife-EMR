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
  , userIdMapCache = new NodeCache({stdTTL: cfg.cache.longTTL, checkperiod: Math.round(cfg.cache.longTTL/10)})
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , addBlankSelectData = require('../util').addBlankSelectData
  , User = {}
  , userCacheKey = 'users'
  , teachersCacheKey = 'teachers'
  ;

/* --------------------------------------------------------
 * hashPassword()
 *
 * Hash the password passed and return the hash as the
 * second parameter of the callback.
 *
 * param      pw
 * param      cb
 * return     undefined
 * -------------------------------------------------------- */
var hashPassword = function(pw, cb) {
  bcrypt.genSalt(10, function(err, salt) {
    bcrypt.hash(pw, salt, function(er2, hash) {
      return cb(null, hash);
    });
  });
};

/* --------------------------------------------------------
 * checkPassword()
 *
 * Check the password against the hash and return the results
 * via the callback.
 *
 * param      pw
 * param      hash
 * param      cb
 * return     undefined
 * -------------------------------------------------------- */
var checkPassword = function(pw, hash, cb) {
  bcrypt.compare(pw, hash, function(err, same) {
    if (err) return cb(err);
    return cb(null, same);
  });
};

// --------------------------------------------------------
// Update the cache of users whenever any cluster worker
// (including this one) updates it.
// --------------------------------------------------------
process.on('message', function(msg) {
  if (msg && msg.cmd && msg.cmd === 'User:saved') {
    userIdMapCache.del(userCacheKey, function() {
      User.getUserIdMap();
    });
    userIdMapCache.del(teachersCacheKey, function() {
      User.getTeachersSelectData();
    });
  }
});

/*
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `firstname` varchar(30) NOT NULL,
  `lastname` varchar(30) NOT NULL,
  `password` varchar(60) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `lang` varchar(10) DEFAULT NULL,
  `shortName` varchar(100) DEFAULT NULL,
  `displayName` varchar(100) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `note` varchar(300) DEFAULT NULL,
  `isCurrentTeacher` tinyint(1) DEFAULT '0',
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `updatedBy` (`updatedBy`),
  KEY `supervisor` (`supervisor`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `user_ibfk_2` FOREIGN KEY (`supervisor`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=latin1
 */
User = Bookshelf.Model.extend({
  // --------------------------------------------------------
  // Instance properties.
  // --------------------------------------------------------
  tableName: 'user'

  , permittedAttributes: ['id', 'username', 'firstname', 'lastname', 'password',
      'email', 'lang', 'shortName', 'displayName', 'status', 'note',
     'isCurrentTeacher', 'updatedBy', 'updatedAt', 'supervisor']
  , initialize: function() {
    this.on('saving', this.saving, this);
    this.on('saved', this.saved, this);
  }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  , saved: function(model) {
    // Inform other cluster workers so that they cay update their cache.
    if (process && process.send) process.send({cmd: 'User:saved'});
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

  /* --------------------------------------------------------
   * findById()
   *
   * Find the user by id.
   * -------------------------------------------------------- */
  findById: function(id, cb) {
    this.forge({id: id})
      .fetch({withRelated: ['roles']})
      .then(function(u) {
        if (! u) return cb(new Error('User id ' + id + ' not found.'));
        return cb(null, u);
      });
  }

    /* --------------------------------------------------------
     * findShortNameById()
     *
     * Find and return the short name of the user by the user's
     * id.
     * -------------------------------------------------------- */
  , findShortNameById: function(id, cb) {
      User.findById(id, function(err, user) {
        if (err) throw err;
        return cb(null, user.get('shortName'));
      });
    }

    /* --------------------------------------------------------
     * findDisplayNameById()
     *
     * Find and return the display name of the user by the user's
     * id.
     * -------------------------------------------------------- */
  , findDisplayNameById: function(id, cb) {
      User.findById(id, function(err, user) {
        if (err) throw err;
        return cb(null, user.get('displayName'));
      });
    }

    /* --------------------------------------------------------
     * findByUsername()
     *
     * Find the user by username.
     * -------------------------------------------------------- */
  , findByUsername: function(username, cb) {
      this.forge({username: username})
        .fetch({withRelated: ['roles']})
        .then(function(u) {
          if (! u) return cb(new Error('User ' + username + ' does not exist.'));
          return cb(null, u);
        });
    }

    /* --------------------------------------------------------
     * checkProfileFields()
     *
     * Check the validity of the profile fields and return the
     * results in the callback.
     * -------------------------------------------------------- */
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

      if (result.messages.length !== 0) {
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

      if (result.messages.length !== 0) {
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
     * getTeachersSelectData()
     *
     * Return a promise that returns a list of users in selectData
     * format that are currently teachers. It also includes a
     * blank first record that is selected. The label is the
     * lastname, firstname concatenated and the key is the user id.
     *
     * return     a promise
     * -------------------------------------------------------- */
  , getTeachersSelectData: function() {
      return new Promise(function(resolve, reject) {
        var knex = Bookshelf.knex
          ;
        userIdMapCache.get(teachersCacheKey, function(err, map) {
          if (err) return reject(err);
          if (map && _.size(map) > 0) {
            return resolve(map[teachersCacheKey]);
          }

          logInfo('User.getTeachersSelectData() - Refreshing cache.');
          knex('user')
            .where('isCurrentTeacher', true)
            .orderBy('lastname', 'asc')
            .select(['id', 'firstname', 'lastname'])
            .then(function(list) {
              var teachers = [];
              _.each(list, function(rec) {
                var t = {};
                t.selectKey = String(rec.id);
                t.label = rec.lastname + ', ' + rec.firstname;
                t.selected = false;
                teachers.push(t);
              });
              addBlankSelectData(teachers);
              userIdMapCache.set(teachersCacheKey, teachers);
              resolve(teachers);
            })
            .caught(function(err) {
              logError(err);
              reject(err);
            });
        });
      });
    }

    /* --------------------------------------------------------
     * getUserIdMap()
     *
     * Returns a promise that returns a hash of users with
     * the keys being their user id as a string and the
     * value being an object with five fields: username,
     * firstname, lastname, shortName and displayName.
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
        userIdMapCache.get(userCacheKey, function(err, map) {
          if (err) return reject(err);
          if (map && _.size(map) > 0) {
            return resolve(map[userCacheKey]);
          }

          logInfo('User.getUserIdMap() - Refreshing user id map cache.');
          knex('user')
            .orderBy('id', 'asc')
            .select(['id', 'username', 'firstname', 'lastname', 'shortName', 'displayName'])
            .then(function(list) {
              var map = {};
              _.each(list, function(user) {
                map[user.id] = user;
              });
              userIdMapCache.set(userCacheKey, map);
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
     * Currently they are username, firstname, lastname,
     * shortName and displayName.
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
