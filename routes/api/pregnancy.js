/*
 * -------------------------------------------------------------------------------
 * pregnancy.js
 *
 * CRUD for pregnancy and related tables.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Pregnancy = require('../../models').Pregnancy
  , Pregnancies = require('../../models').Pregnancies
  , EventTypes = require('../../models').EventTypes
  , cfg = require('../../config')
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , validOrVoidDate = require('../../util').validOrVoidDate
  , prenatalCheckInId
  , prenatalCheckOutId
  ;

/* --------------------------------------------------------
 * init()
 *
 * A one time load of certain values from the database.
 * -------------------------------------------------------- */
var init = function() {

  // --------------------------------------------------------
  // Do a one time load of EventType ids.
  // --------------------------------------------------------
  new EventTypes()
    .fetch()
    .then(function(list) {
      prenatalCheckInId = list.findWhere({name: 'prenatalCheckIn'}).get('id');
      prenatalCheckOutId = list.findWhere({name: 'prenatalCheckOut'}).get('id');
    });

};


var getPregnancy = function(req, res) {
  var pregId = req.parameters.id1? parseInt(req.parameters.id1, 10): void 0
    , fetchObject = {withRelated: [
        'patient'
        , 'priority'
        , 'schedule'
        , 'customField'
        ]
      }
    ;

  if (_.isNumber(pregId) && ! _.isNaN(pregId)) {
    Pregnancy.forge({id: pregId})
      .fetch(fetchObject)
      .then(function(pregRec) {
        // Convert to JSON.
        return pregRec.toJSON();
      })
      .then(function(json) {
        // Massage priority field from array to a field.
        // (Add fields as priority types are added.)
        if (_.isArray(json.priority) && json.priority.length > 0) {
          json.prenatalCheckinPriority = _.findWhere(json.priority, {eType: prenatalCheckInId}).priority;
        }
        if (! json.prenatalCheckinPriority) json.prenatalCheckinPriority = 0;
        delete json.priority;
        return json;
      })
      .then(function(json) {
        // Massage the prenatal schedule field from array into fields.
        // (Adjust as schedule types are added.)
        if (_.isArray(json.schedule) && json.schedule.length > 0) {
          json.prenatalLocation = _.findWhere(json.schedule, {scheduleType: 'Prenatal'}).location;
          json.prenatalDay = _.findWhere(json.schedule, {scheduleType: 'Prenatal'}).day;
        }
        if (! json.prenatalLocation) json.prenatalLocation = '';
        if (! json.prenatalDay) json.prenatalDay = '';
        delete json.schedule;
        return json;
      })
      .then(function(json) {
        console.dir(json);
        return json;
      })
      .then(function(pregJson) {
        res.end(JSON.stringify(pregJson));
      });
  } else {
    // Pregnancy id not passed from client.
    res.end();
  }
};

// Initialize the module.
init()

module.exports = {
  getPregnancy: getPregnancy
};
