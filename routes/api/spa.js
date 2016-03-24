/*
 * -------------------------------------------------------------------------------
 * spa.js
 *
 * Load the page for the SPA portion of the application.
 * -------------------------------------------------------------------------------
 */
var _ = require('underscore')
  , cfg = require('../../config')
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
  var data;
  logInfo('op1: ' + req.parameters.op1);
  switch(req.parameters.op1) {
    case 'history':
      data = {
        pregId: req.parameters.id1
        , exitUrl: req.url.replace(/\/spa\/history/, '')
      };
      switch(req.parameters.op2) {
        case 'pregnancy':
          // TODO: Replace these hard-coded paths with paths from config.
          // TODO: Add all of the paths or allow anything.
          switch(req.parameters.op3) {
            case 'prenatal':
            case 'labs':
            case 'quesEdit':
            case 'midwifeinterview':
            case 'edit':
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
    case 'admin':
      // --------------------------------------------------------
      // The data that we load into the app when it loads.
      //
      // Note: this is wrapped in an outer object below and
      // stringified in the Jade template before being sent to
      // the client.
      // --------------------------------------------------------
      //data = {
        //// This confirms to the Cfg interface on the client.
        //cfg: {
          //siteTitle: cfg.site.title
          //, siteTitleLong: cfg.site.titleLong
        //}
      //};
      //logInfo('Loading Midwife-EMR with this data:');
      //console.log(JSON.stringify(data));
      //res.render('main', {cfg: data});
      break;
    default:
      logError('op1 unknown: ' + req.parameters.op1);
      res.redirect(cfg.path.search);
  }
};

module.exports = {
  main: main
};

