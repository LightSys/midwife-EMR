/*
 * -------------------------------------------------------------------------------
 * Schedule.js
 *
 * The model for schedules, e.g. prenatal schedule, etc. A schedule is a set day
 * that a specific patient is supposed to come to the clinic on a regular basis.
 * In the case of prenatal exams, some patients would be assigned to Tuesday while
 * others Wednesday or Friday, etc. This spreads out the clients throughout the
 * week and allows the clients to have a consistent schedule, i.e. the same day
 * of the week (though probably not every week).
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , Schedule = {}
  ;

/*
CREATE TABLE IF NOT EXISTS `schedule` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  scheduleType VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  day VARCHAR(20) NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  UNIQUE (pregnancy_id, scheduleType),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
*/

Schedule = Bookshelf.Model.extend({
  tableName: 'schedule'

  , permittedAttributes: ['id', 'scheduleType', 'location', 'day',
      'updatedBy', 'updatedAt', 'supervisor', 'pregnancy_id']

  , initialize: function() {
      this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  // --------------------------------------------------------

  , pregnancy: function() {
      return this.belongsTo(require('./Pregnancy').Pregnancy, 'pregnancy_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

Schedules = Bookshelf.Collection.extend({
  model: Schedule
});

module.exports = {
  Schedule: Schedule
  , Schedules: Schedules
};

