/* 
 * -------------------------------------------------------------------------------
 * error.js
 *
 * Application wide error handling.
 * ------------------------------------------------------------------------------- 
 */


var notFoundError = function(req, res) {
  var title = req.gettext("Oops! Couldn't find that page.")
    , text = "We've saved what happened so that we can figure it out later. In the meantime, choose the Home menu option to try again.";
    ;
  console.log('User: ' + req.session.user.id + ', path: ' + req.path + ', method: ' + req.method);
  res.render('errorPage', {title: title, text: text});
};

/* --------------------------------------------------------
 * logError()
 *
 * Log the error to stderr.
 * -------------------------------------------------------- */
var logError = function(err, req, res, next) {
  if (process.env.NODE_ENV == 'test' && (! process.env.NODE_ENV_VERBOSE)) {
    return next(err);
  }
  console.error('----------------------------------------');
  console.error(err.message);
  if (err.details) console.error(err.details);
  console.error(err.stack);
  console.error('----------------------------------------');
  next(err);
};

var displayError = function(err, req, res, next) {
  var title = req.gettext("Oops!")
    , text = "We've saved what happened so that we can figure it out later. In the meantime, choose the Home menu option to try again.";
    ;
  if (err.status === 403) {
    res.status(403);
    text = 'It seems that you are not authorized for that page. Sorry.';
  }
  res.render('errorPage', {title: title, text: text});
  //next(err);
};

/* --------------------------------------------------------
 * exitError()
 *
 * Exit the process.
 * -------------------------------------------------------- */
var exitError = function(err, req, res, next) {
  console.error('Exiting application due to error.');
  process.exit(1);
};


module.exports = {
  logError: logError
  , notFoundError: notFoundError
  , displayError: displayError
  , exitError: exitError
};


