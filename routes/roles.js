/* 
 * -------------------------------------------------------------------------------
 * roles.js
 *
 * Functionality for the management of roles.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , Role = require('../models').Role
  , Roles = require('../models').Roles
  , cfg = require('../config')
  ;

/* --------------------------------------------------------
 * load()
 *
 * Loads the role record from the database based upon the id
 * as specified in the path. Places the role record in the
 * request as paramRole.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var load = function(req, res, next) {
  var id = req.params.id
    ;

  Role.forge({id: id})
    .fetch()
    .then(function(rec) {
      if (! rec) return next();
      rec = rec.toJSON();
      if (rec) req.paramRole = rec;
      next();
    });
};

/* --------------------------------------------------------
 * list()
 *
 * Renders a screen that lists the roles in the system. Does
 * not render the updatedBy and supervisor fields.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var list = function(req, res) {
  var omit = ['updatedBy', 'supervisor'];
  Roles.forge()
    .fetch()
    .then(function(list) {
      var roleList = [];
      list.forEach(function(rec) {
        roleList.push(_.omit(rec.toJSON(), omit));
      });
      res.render('roleList', {
        title: req.gettext('List of Roles')
        , user: req.session.user
        , roles: roleList
      });
    });
};

/* --------------------------------------------------------
 * addForm()
 *
 * Renders the form used to add a new role into the system.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var addForm = function(req, res) {
  var blankRole = {
      name: ''
      , description: ''
    }
    ;
  res.render('roleAddForm', {
    title: req.gettext('Add Role')
    , user: req.session.user
    , success: true
    , messages: []
    , editRole: blankRole
  });
};

/* --------------------------------------------------------
 * getEditFormData()
 *
 * Returns an object representing the data that is rendered
 * when the edit form is displayed.
 *
 * param       req
 * param       addData  - (Object) additional data
 * return      Object
 * -------------------------------------------------------- */
var getEditFormData = function(req, addData) {
  return _.extend(addData, {
    title: req.gettext('Edit Role')
    , user: req.session.user
    , editRole: req.paramRole
  });
};

/* --------------------------------------------------------
 * editForm()
 *
 * Renders the form used to edit a role.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var editForm = function(req, res) {
  if (req.paramRole) {
    res.render('roleEditForm', getEditFormData(req, {success: true, messages: []}));
  } else {
    res.redirect(cfg.path.roleList);
  }
};

/* --------------------------------------------------------
 * update()
 *
 * Updates the role in the database after checking the fields
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var update = function(req, res) {
  var data = {}
    , fldsToOmit = ['_csrf']
    ;
  if (req.paramRole &&
      req.body &&
      req.paramRole.id &&
      req.body.id &&
      req.paramRole.id == req.body.id) {
    Role.checkFields(req.body, false, function(err, result) {
      var editObj
        , role
        ;
      if (result.success) {
        editObj = _.extend({
                      updatedBy: req.session.user.id
                    }, _.omit(req.body, fldsToOmit));
        Role.forge(editObj)
          .save(null, {method: 'update'})
          .then(function(model) {
            res.redirect(cfg.path.roleList);
          });
      } else {
        data.success = false;
        data.messages = result.messages;
        res.render('roleEditForm', getEditFormData(req, data));
      }
    });
  } else {
    console.error('Error in update of role: role not found.');
    res.redirect(cfg.path.roleList);
  }
};


/* --------------------------------------------------------
 * create()
 *
 * Creates the role after sanity checking the fields for
 * validity.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var create = function(req, res) {
  var data = {
      title: req.gettext('Add Role')
      , user: req.session.user
      , messages: [req.gettext('Role was created.')]
      , success: true
  };
  Role.checkFields(req.body, true, function(err, result) {
    var newRoleObj
      , role
      ;

    if (result.success) {
      newRoleObj = _.extend({updatedBy: req.session.user.id
                  }, _.omit(req.body, ['_csrf']));
      Role.forge(newRoleObj)
        .save()
        .then(function(model) {
          res.redirect(cfg.path.roleList);
        });
    } else {
      data.success = false;
      data.messages = result.messages;
      res.render('roleAddForm', data);
    }
  });
};


module.exports = {
  list: list
  , addForm: addForm
  , create: create
  , load: load
  , editForm: editForm
  , update: update
};

