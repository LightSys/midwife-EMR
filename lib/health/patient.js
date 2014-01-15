/* 
 * -------------------------------------------------------------------------------
 * patient.js
 *
 * The business object interface to a patient.
 * ------------------------------------------------------------------------------- 
 */

var dbSettings = require('./../../config').database
  , DB = (require('bookshelf').DB || require('../../models/DB').init(dbSettings))
  , Patient = require('../../models/Patient').Patient
  , Patients = require('../../models/Patient').Patients
  , patient = {}
  ;

/* --------------------------------------------------------
 * create()
 *
 * Create a new patient record. Returns the id of the patient
 * to the caller via the callback.
 *
 * TODO: might consider returning the JSON of the newly 
 * created patient in order to save another call into the
 * business layer and the database to get this information.
 *
 * param       data - object with the keys/values for columns
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
patient.create = function(data, cb) {
  Patient.forge(data)
    .save()
    .then(function(model) {
      if (model) return cb(null, model.id);
      return cb(new Error('Patient not created'));
    });
};

/* --------------------------------------------------------
 * delete()
 *
 * Delete the patient record based upon id. "On delete
 * cascade" is specified in the database so relevent records
 * in related tables will also be deleted.
 *
 * param       id
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
patient.delete = function(id, cb) {
  if (id) {
    Patient.forge({id: id})
      .destroy()
      .then(function() {
        return cb();
      });
  } else {
    return cb('id must be supplied');
  }
};

/* --------------------------------------------------------
 * find()
 *
 * Find one or more patients using any field and value specified in
 * the object passed. If the key id is passed in data, it
 * alone will be used to identify the record. Returns an 
 * array of JSON objects to the caller via the callback.
 *
 * param       data
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
patient.find = function(data, cb) {
  Patient.forge()
    .query()
    .where(data)
    .then(function(pList) {
      return cb(null, pList);
    });
};


/* --------------------------------------------------------
 * update()
 *
 * Update the patient record using the field names and values
 * passed.
 *
 * Note: the id of the record to update must be passed within
 * the data parameter. The id will not be updated but used to
 * locate the record to update.
 *
 * param       data
 * param       cb - callback
 * return      undefined
 * -------------------------------------------------------- */
patient.update = function(data, cb) {
  var id;
  if (data && data.id) {
    id = data.id;
    delete data.id;
    Patient.forge({id: id})
      .set(data)
      .save()
      .then(function(p) {
        return cb(null);
      });
  } else {
    return cb(new Error('Must supply the id of the record to update'));
  }
};


module.exports = patient;

