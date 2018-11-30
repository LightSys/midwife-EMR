/* 
 * -------------------------------------------------------------------------------
 * ClientConsole.js
 *
 * Table which records the console log messages from the L&D clients.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , ClientConsole = {}
  , ClientConsoles
  ;


/*
CREATE TABLE `clientConsole` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) DEFAULT NULL,
  `session_id` varchar(300) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `severity` enum('info','warning','error','debug','other') NOT NULL,
  `message` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user` (`user`),
  CONSTRAINT `clientConsole_ibfk_1` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1
*/

ClientConsole = Bookshelf.Model.extend({
  tableName: 'clientConsole'

    // NOTE: 'id' is not included by default because it is created upon insert and
    // we are not allowing updates, etc.
  , permittedAttributes: ['user', 'session_id', 'timestamp', 'severity', 'message']

    // --------------------------------------------------------
    // Flag for the super class to use to determine if the updatedAt
    // field should not be set automatically and the updatedBy and
    // supervisor fields should not be required either.
    // --------------------------------------------------------
  , noLogging: true

  // --------------------------------------------------------
  // Relationships
  //
  // Note: avoid circular references by using require() inline.
  // https://github.com/tgriesser/bookshelf/issues/105
  // --------------------------------------------------------

  , user: function() {
      return this.belongsTo(require('./User').User, 'user');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

ClientConsoles = Bookshelf.Collection.extend({
  model: ClientConsole
});

module.exports = {
  ClientConsole
  , ClientConsoles
};


