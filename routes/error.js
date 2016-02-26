/*
 * -------------------------------------------------------------------------------
 * error.js
 *
 * Application wide error handling.
 * -------------------------------------------------------------------------------
 */

var logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , cfg = require('../config')
  ;

/* --------------------------------------------------------
 * isClientError()
 *
 * Return true if the error status represents a client error
 * that should not trigger a restart.
 *
 * "stolen" from:
 * https://github.com/dilvie/express-error-handler/blob/master/error-handler.js
 *
 * param       status - number
 * return      boolean - true if a client error
 * -------------------------------------------------------- */
isClientError = function isClientError(status) {
  return (status >= 400 && status <= 499);
};

/* --------------------------------------------------------
 * notFoundApiError()
 *
 * If it is an API call, do not return a not found page but
 * instead return an appropriate error code.
 * -------------------------------------------------------- */
var notFoundApiError = function(req, res, next) {
  if (/^\/api/.test(req.path)) {
    logInfo('API call not found: ' + req.path + ', method: ' + req.method);
    res.status(404);
    res.end();
  } else {
    next();
  }
};

/* --------------------------------------------------------
 * notFoundError()
 *
 * Display a not found page. This is not a fatal error.
 * -------------------------------------------------------- */
var notFoundError = function(req, res) {
  var title = req.gettext("Oops! Couldn't find that page.")
    , text = "We've saved what happened so that we can figure it out later. In the meantime, choose the Home menu option to try again."
    ;
  if (req.session && req.session.user && req.session.user.id) {
    logInfo('Not found - User: ' + req.session.user.id + ', path: ' + req.path + ', method: ' + req.method);
  } else {
    logInfo('Not found - Path: ' + req.path + ', method: ' + req.method);
  }
  res.render('errorPage', {title: title, text: text});
};

/* --------------------------------------------------------
 * logException()
 *
 * Log the error to stderr.
 * -------------------------------------------------------- */
var logException = function(err, req, res, next) {
  var msg = ''
    ;
  if (process.env.NODE_ENV == 'test' && (! process.env.NODE_ENV_VERBOSE)) {
    return next(err);
  }
  if (err.status) msg += 'Status: ' + err.status + ' ';
  if (err.details) msg += err.details;
  if (msg.length) logError(msg);
  if (! isClientError(err.status)) logError(err.stack);
  next(err);
};

/* --------------------------------------------------------
 * displayError()
 *
 * Display an appropriate error page to the user.
 * -------------------------------------------------------- */
var displayError = function(err, req, res, next) {
  var title = req.gettext("Oops!")
    , text = "We've saved what happened so that we can figure it out later. In the meantime, choose the Home menu option to try again."
    ;
  if (err.status === 403) {
    res.status(403);
    if (req.url === cfg.path.login) {
      req.flash('warning', req.gettext('Sorry, you tried to login using a stale login page. Please try again using this one.'));
      return res.redirect(cfg.path.login);
    } else {
      text = 'It seems that you are not authorized for that page. Sorry.';
    }
  }
  res.render('errorPage', {title: title, text: text});
  next(err);
};

/* --------------------------------------------------------
 * exitError()
 *
 * Exit the process after waiting for the error page to
 * be rendered, etc.
 * -------------------------------------------------------- */
var exitError = function(err, req, res, next) {
  if (isClientError(err.status)) return;  // return only since render has already occurred.
  logError('Aborting process in ' + cfg.error.errorTimeout + ' milliseconds.');
  setTimeout(function() {
    logError('Exiting application due to error.');
    process.exit(1);
  }, cfg.error.errorTimeout);
};


module.exports = {
  logException: logException
  , notFoundError: notFoundError
  , notFoundApiError: notFoundApiError
  , displayError: displayError
  , exitError: exitError
};


