/*
 * -------------------------------------------------------------------------------
 * User.js
 *
 * The model for user data.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , bcrypt = require('bcrypt')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , User = {}
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

  , permittedAttributes: ['id', 'username','password','email','lang',
         'status', 'updatedBy', 'updatedAt', 'supervisor']

  , initialize: function() {
    this.on('saving', this.saving, this);
  }

  , saving: function() {
    console.log('saving');
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

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------
}, {
  // --------------------------------------------------------
  // Class properties.
  // --------------------------------------------------------
  findById: function(id, cb) {
    this.forge({id: id})
      .fetch()
      .then(function(u) {
        if (! u) return cb(new Error('User id ' + id + ' not found.'));
        return cb(null, u);
      });
  }

  , findByUsername: function(username, cb) {
    this.forge({username: username})
      .fetch()
      .then(function(u) {
        if (! u) return cb(new Error('User ' + username + ' does not exist.'));
        // TODO: security issues with password hash, etc.
        return cb(null, u);
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
