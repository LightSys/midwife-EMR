/*
 * -------------------------------------------------------------------------------
 * spa.js
 *
 * Load the page for the SPA portion of the application.
 * -------------------------------------------------------------------------------
 */
var cfg = require('../../config')
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  ;

/* --------------------------------------------------------
 * main()
 *
 * Render the main entry point for the SPA portion of the
 * application.
 * -------------------------------------------------------- */
var main = function(req, res) {
  var data = {
    pregId: req.parameters.id1
  };
  switch(req.parameters.op1) {
    case 'history':
      switch(req.parameters.op2) {
        case 'pregnancy':
          switch(req.parameters.op3) {
            case 'prenatal':
              // Take user back to prenatal page when leaving history mode.
              data.exitUrl = req.url.replace(/\/spa\/history/, '');
              res.render('spa', data);
              break;
            default:
              logError('Unsupported SPA call: ' + req.path);
              res.redirect(cfg.path.search);
          }
          break;
        default:
          logError('op2 unknown: ' + req.parameters.op2);
          res.redirect(cfg.path.search);
      }
      break;
    default:
      logError('op1 unknown: ' + req.parameters.op1);
      res.redirect(cfg.path.search);
  }
};

module.exports = {
  main: main
};

