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
  , cfg = require('../../config')
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , validOrVoidDate = require('../../util').validOrVoidDate
  ;


var getPregnancy = function(req, res) {
  var pregId = req.parameters.id1? parseInt(req.parameters.id1, 10): void 0
    , fetchObject = {withRelated: [
        'patient'
        //, 'priority'
        //, 'schedule'
        //, 'customField'
        ]
      }
    ;

  if (_.isNumber(pregId) && ! _.isNaN(pregId)) {
    Pregnancy.forge({id: pregId})
      .fetch(fetchObject)
      .then(function(pregRec) {
        console.dir(pregRec.toJSON());
        return pregRec.toJSON();
      })
      .then(function(pregJson) {
        res.end(JSON.stringify(pregJson));
      });
  } else {
    // Pregnancy id not passed from client.
    res.end();
  }
};

module.exports = {
  getPregnancy: getPregnancy
};
