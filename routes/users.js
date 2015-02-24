/*
 * -------------------------------------------------------------------------------
 * users.js
 *
 * Functionality for the management of users.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , Promise = require('bluebird')
  , hasRole = require('../auth').hasRole
  , User = require('../models').User
  , Users = require('../models').Users
  , Role = require('../models').Role
  , Roles = require('../models').Roles
  , Event = require('../models').Event
  , cfg = require('../config')
  , auth = require('../auth')
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , languageList = []
  ;

/* --------------------------------------------------------
 * init()
 *
 * Initialize the module.
 * -------------------------------------------------------- */
var init = function() {
  // --------------------------------------------------------
  // Initialize the languages available for the profile page.
  // --------------------------------------------------------
  _.each(cfg.site.languagesMap, function(val, key) {
    var lang = {}
      ;
    lang.selectKey = key;
    lang.label = val;
    lang.selected = false;
    languageList.push(lang);
  });
};

/* --------------------------------------------------------
 * load()
 *
 * Loads the user record from the database based upon the id
 * as specified in the path. Places the user record in the
 * request as paramUser. Does not include the password field.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var load = function(req, res, next) {
  var id = req.params.id
    ;

  User.forge({id: id})
    .fetch({withRelated: ['roles']})
    .then(function(rec) {
      if (! rec) return next();
      rec = _.omit(rec.toJSON(), ['password']);
      if (rec) req.paramUser = rec;
      next();
    });
};

/* --------------------------------------------------------
 * getProfileFormData()
 *
 * Returns an object representing the data that is rendered
 * when the profile form is displayed.
 *
 * param       req
 * param       addData  - (Object) additional data
 * return      Object
 * -------------------------------------------------------- */
var getProfileFormData = function(req, addData) {
  return _.extend(addData, {
    title: req.gettext('Edit Your Profile')
    , user: req.session.user
  });
};

/* --------------------------------------------------------
 * editSupervisor()
 *
 * Display the form to allow the attending to choose their
 * supervisor.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var editSupervisor = function(req, res) {
  var omit = ['password', 'updatedBy', 'supervisor', 'roles',
      'updatedAt', 'email', 'lang', 'status', 'note']
    , users = new Users()
    , data = {
        title: req.gettext('Choose your supervisor')
        , user: req.session.user
        , messages: req.flash()
      }
    , currSuper
    ;

  if (req.session.supervisor) {
    currSuper = req.session.supervisor.firstname + ' ' +
      req.session.supervisor.lastname;
  }

  users
    .fetch({withRelated: 'roles'})
    .then(function(list) {
      var userList = [];
      list.forEach(function(rec) {
        var roles = rec.related('roles').toJSON();
        if (_.contains(_.pluck(roles, 'name'), 'supervisor')) {
          userList.push(_.omit(rec.toJSON(), omit));
        }
      });
      data.userList = userList;
      data.supervisor = currSuper || void(0);
      res.render('setSuper', data);
    });
};


/* --------------------------------------------------------
 * saveSupervisor()
 *
 * Save the attending's choice of a supervisor.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var saveSupervisor = function(req, res) {
  var supervisor = req.body.supervisor || -1
    ;
  try {
    supervisor = parseInt(supervisor, 10);
  } catch (e) {
    supervisor = -1;
  }

  if (supervisor !== -1) {
    User.forge({id: supervisor})
      .fetch({withRelated: ['roles']})
      .then(function(rec) {
        var roles
          , options = {}
          ;
        if (rec) {
          roles = rec.related('roles').toJSON();
          if (_.contains(_.pluck(roles, 'name'), 'supervisor')) {
            req.session.supervisor = {};
            req.session.supervisor.id = rec.get('id');
            req.session.supervisor.username = rec.get('username');
            req.session.supervisor.firstname = rec.get('firstname');
            req.session.supervisor.lastname = rec.get('lastname');
            req.session.supervisor.displayName = rec.get('displayName');
            req.session.save();
            req.flash('info', req.gettext('Your supervisor has been set.'));

            // Returns a promise but we don't handle how it is resolved.
            options.sid = req.sessionID;
            options.user_id = req.session.user.id;
            Event.setSuperEvent(options);
          } else {
            logError('User selected is not a supervisor!');
            req.flash('warning', req.gettext('An error occurred. Please try again.'));
          }
        } else {
          logError('User not found!');
          req.flash('warning', req.gettext('An error occurred. Please try again.'));
        }
        res.redirect(cfg.path.setSuper);
      });
  } else {
    req.flash('info', req.gettext('Please choose your supervisor.'));
    res.redirect(cfg.path.setSuper);
  }
};

/* --------------------------------------------------------
 * editProfile()
 *
 * Loads the profile form for the user.
 *
 * param       req
 * param       res
 * param       next - callback
 * return      undefined
 * -------------------------------------------------------- */
var editProfile = function(req, res) {
  var profile
    , omit = ['password', 'status', 'note', 'updatedBy', 'updatedAt', 'supervisor']
    , additionalData = {
        success: true
        , messages: req.flash()
        , profile: {}
    }
    , formdata
    , languages = _.map(languageList, function(l) {return _.clone(l);})
    ;

  User.forge({id: req.session.user.id})
    .fetch()
    .then(function(rec) {
      var r = _.omit(rec.toJSON(), omit);
      additionalData.profile = r;

      // --------------------------------------------------------
      // Properly populate the language selection.
      // --------------------------------------------------------
      if (r.lang && r.lang.length > 0) {
        _.each(languages, function(rec) {
          if (r.lang == rec.selectKey) rec.selected = true;
        });
      }
      additionalData.profile.lang = languages;

      res.render('profileForm', getProfileFormData(req, additionalData));
    });
};

/* --------------------------------------------------------
 * saveProfile()
 *
 * Updates the current user in the database after checking
 * the fields for validity. If password is specified, checks
 * then hashes the password before saving.
 *
 * TODO: update the record stored in req.session.user upon
 * successful update.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var saveProfile = function(req, res) {
  var processPw = true
    , fldsToOmit = ['password2','_csrf']
    , supervisor = null   // supervisor should not be needed here but for consistency
    ;

  // Insure we only save for ourselves.
  if (req.body &&
      req.body.id &&
      req.body.id == req.session.user.id) {
    if (req.body.password.length == 0 || req.body.password2.length == 0) {
      processPw = false;
    }
    User.checkProfileFields(req.body, processPw, function(err, result) {
      var editObj
        , user
        ;
      if (result.success) {
        if (! processPw) {
          // If the password is not specified, do not replace it with an
          // empty string in the database.
          fldsToOmit.push('password');
        }
        editObj = _.extend({
                      updatedBy: req.session.user.id
                    }, _.omit(req.body, fldsToOmit));
        user = new User(editObj);
        if (hasRole(req, 'attending')) {
          supervisor = req.session.supervisor.id;
        }
        if (processPw) {
          user.hashPassword(editObj.password, function(er2, success) {
            if (er2) return logError(er2);
            user
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(supervisor)
              .save(null, {method: 'update'})
              .then(function(model) {
                // --------------------------------------------------------
                // Update the user's session with the language preference.
                // --------------------------------------------------------
                req.session.user.lang = model.get('lang');
                req.session.save();

                req.flash('info', req.gettext('Your profile has been saved.'));
                res.redirect(cfg.path.profile);
              });
          });
        } else {
          user
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(req.session.user.id)
            .save(null, {method: 'update'})
            .then(function(model) {
              // --------------------------------------------------------
              // Update the user's session with the language preference.
              // --------------------------------------------------------
              req.session.user.lang = model.get('lang');
              req.session.save();

              req.flash('info', req.gettext('Your profile has been saved.'));
              res.redirect(cfg.path.profile);
            });
        }
      } else {
        _.each(result.messages, function(msg) {
          req.flash('error', msg);
        });
        res.redirect(cfg.path.profile);
      }
    });
  } else {
    if (req.body && req.body.id && req.body.id != req.session.user.id) {
      res.send(403, 'Forbidden');
    }
  }
};

/* --------------------------------------------------------
 * list()
 *
 * Renders a screen that lists the users in the system. Does
 * not render the password, updatedBy, supervisor or
 * password fields. Renders status as Yes or No.
 *
 * Accepts query params of status and role. Acceptable values
 * for status are 0 and 1 and for role 0 through 5 with 0
 * representing all roles and 1 through 5 the respective
 * role id. An url without status or role specified is the
 * same as all statuses and roles.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var list = function(req, res) {
  var status = req.query.status
    , role = req.query.role
    , omit = ['password', 'updatedBy', 'supervisor']
    , constraint = {}
    ;

  // --------------------------------------------------------
  // Sanity checks, default for status is undefined and for
  // role it is 0.
  // --------------------------------------------------------
  status = parseInt(status, 10);
  if (isNaN(status)) status = void(0);
  if (status !== 0 && status !== 1) status = void(0);
  role = parseInt(role, 10);
  if (isNaN(role)) role = 0;
  if (role < 0 || role > 5) role = 0;

  Users.forge()
    .query(function(qb) {
      if (! isNaN(status)) qb.where('status', '=', status);
    })
    .fetch({withRelated: ['roles']})
    .then(function(list) {
      var userList = [];
      list.forEach(function(rec) {
        var r = rec.toJSON()
          , sts = r.status
          , roles
          ;
        r.status = req.gettext('Yes');
        if (sts == 0) r.status = req.gettext('No');

        if (role) {
          roles = _.pluck(r.roles, 'id');
          if (_.indexOf(roles, role) !== -1) {
            userList.push(_.omit(r, omit));
          }
        } else {
          userList.push(_.omit(r, omit));
        }
      });
      res.render('userList', {
        title: req.gettext('List of Users')
        , user: req.session.user
        , messages: req.flash()
        , users: userList
      });
    });
};

/* --------------------------------------------------------
 * addForm()
 *
 * Renders the form used to add a new user into the system.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var addForm = function(req, res) {
  var blankUser = {
      username: ''
      , firstname: ''
      , lastname: ''
      , password: ''
      , email: ''
      , lang: ''
      , displayName: ''
      , 'status': ''
      , note: ''
    }
    ;
  res.render('userAddForm', {
    title: req.gettext('Add User')
    , user: req.session.user
    , success: true
    , messages: req.flash()
    , editUser: blankUser
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
    title: req.gettext('Edit User')
    , user: req.session.user
    , messages: req.flash()
    , editUser: _.extend(req.paramUser, {password: '', password2: ''})
  });
};

/* --------------------------------------------------------
 * editForm()
 *
 * Renders the form used to edit a user.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var editForm = function(req, res) {
  var roles = []
    , formData
    , additionalData = {
        success: true
        , roles: null
    }
    ;
  if (req.paramUser) {
    // --------------------------------------------------------
    // Pass all the roles available for the roles listing
    // to the template.
    // --------------------------------------------------------
    Roles.forge()
      .fetch()
      .then(function(list) {
        for (var i = 0; i < list.length; i++) {
          roles.push(list.at(i).toJSON());
        }
        additionalData.roles = roles;
        formData = getEditFormData(req, additionalData);
        res.render('userEditForm', formData);
      });
  } else {
    res.redirect(cfg.path.userList);
  }
};

/* --------------------------------------------------------
 * update()
 *
 * Updates the user in the database after checking the fields
 * for validity. If password is specified, checks then hashes
 * the password before saving.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var update = function(req, res) {
  var processPw = true
     , data = {}
    , fldsToOmit = ['password2','_csrf']
    , supervisor = null
    , defaultFlds = {
        isCurrentTeacher: '0'
        , status: '0'
      }
    ;
  if (req.paramUser &&
      req.body &&
      req.paramUser.id &&
      req.body.id &&
      req.paramUser.id == req.body.id) {
    if (req.body.password.length == 0 || req.body.password2.length == 0) {
      processPw = false;
    }
    User.checkFields(req.body, false, processPw, function(err, result) {
      var editObj
        , user
        ;
      if (result.success) {
        if (! processPw) {
          // If the password is not specified, do not replace it with an
          // empty string in the database.
          fldsToOmit.push('password');
        }

        // --------------------------------------------------------
        // Set field defaults which allows unsettings checkboxes.
        // --------------------------------------------------------
        editObj = _.extend(defaultFlds, {updatedBy: req.session.user.id}, _.omit(req.body, fldsToOmit));
        user = new User(editObj);
        if (hasRole(req, 'attending')) {
          supervisor = req.session.supervisor.id;
        }
        if (processPw) {
          user.hashPassword(editObj.password, function(er2, success) {
            if (er2) return logError(er2);
            user
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(supervisor)
              .save(null, {method: 'update'})
              .then(function(model) {
                res.redirect(cfg.path.userList);
              });
          });
        } else {
          user
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(supervisor)
            .save(null, {method: 'update'})
            .then(function(model) {
              res.redirect(cfg.path.userList);
            });
        }
      } else {
        data.success = false;
        _.each(result.messages, function(msg) {
          req.flash('warning', msg);
        });
        // Redirect allows rebuilding of roles, etc.
        res.redirect(cfg.path.userList + '/' + req.body.id + '/edit');
      }
    });
  } else {
    logError('Error in update of user: user not found.');
    res.redirect(cfg.path.userList);
  }
};

/* --------------------------------------------------------
 * create()
 *
 * Creates the user after sanity checking the fields for
 * validity.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var create = function(req, res) {
  var data = {
        title: req.gettext('Add User')
        , user: req.session.user
        , success: true
      }
    , supervisor = null
    ;
  User.checkFields(req.body, true, true, function(err, result) {
    var newUserObj
      , user
      ;

    if (result.success) {
      if (hasRole(req, 'attending')) {
        supervisor = req.session.supervisor.id;
      }
      newUserObj = _.extend({status: 1
                  , updatedBy: req.session.user.id
                  }, _.omit(req.body, ['password2', '_csrf']));
      user = new User(newUserObj);
      user.hashPassword(newUserObj.password, function(err, success) {
        if (err) return logError(err);
        user
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(supervisor)
          .save()
          .then(function(model) {
            req.flash('info', req.gettext('User was created.'));
            res.redirect(cfg.path.userList);
          });
      });
    } else {
      data.success = false;
      _.each(result.messages, function(msg) {
        req.flash('warning', msg);
      });
      data.messages = req.flash();
      res.render('userAddForm', data);
    }
  });
};

/* --------------------------------------------------------
 * changeRoles()
 *
 * Update the roles that are associated with the user
 * through insertions and deletions in the user_role
 * table.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var changeRoles = function(req, res) {
  var newRoles = []
    , currRoles = _.pluck(req.paramUser.roles, 'id')
    , additions = []
    , deletions = []
    , rid
    ;

  // --------------------------------------------------------
  // Convert roles from the form from string to int.
  // --------------------------------------------------------
  _.each(req.body.roles, function(r) {
    newRoles.push(parseInt(r, 10));
  });

  Roles.forge()
    .fetch()
    .then(function(roles) {
      // --------------------------------------------------------
      // Populate the additions and deletions arrays of role ids
      // that need to change.
      // --------------------------------------------------------
      for (var i = 0; i < roles.length; i++ ) {
        rid = roles.at(i).get('id');
        if (_.contains(newRoles, rid)) {
          if (! _.contains(currRoles, rid)) {
            additions.push({
              user_id: req.paramUser.id
              , role_id: rid
              , updatedBy: req.session.user.id
              , supervisor: req.session.supervisor
              , updatedAt: new Date()
	    });
          }
        } else {
          if (_.contains(currRoles, rid)) {
            deletions.push(rid);
          }
        }
      }

      // --------------------------------------------------------
      // Save the changes to the database.
      // --------------------------------------------------------
      User.forge({id: req.paramUser.id})
        .related('roles')
        .detach(deletions)
        .then(function() {
          User.forge({id: req.paramUser.id})
            .related('roles')
            .attach(additions)
            .then(function() {
              res.redirect(cfg.path.userList);
            });
        });
    });
};

// --------------------------------------------------------
// Initialize the module.
// --------------------------------------------------------
init();

module.exports = {
  list: list
  , addForm: addForm
  , create: create
  , load: load
  , editForm: editForm
  , update: update
  , changeRoles: changeRoles
  , editProfile: editProfile
  , saveProfile: saveProfile
  , editSupervisor: editSupervisor
  , saveSupervisor: saveSupervisor
};


