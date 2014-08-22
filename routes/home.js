/*
 * -------------------------------------------------------------------------------
 * home.js
 *
 * Routes for home and logging in.
 * -------------------------------------------------------------------------------
 */

var passport = require('passport')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , NodeCache = require('node-cache')
  , cfg = require('../config')
  , longCache = new NodeCache({stdTTL: cfg.cache.longTTL, checkperiod: Math.round(cfg.cache.longTTL/10)})
  , shortCache = new NodeCache({stdTTL: cfg.cache.shortTTL, checkperiod: Math.round(cfg.cache.shortTTL/10)})
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , loginRoute = '/login'
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , _ = require('underscore')
  , Event = require('../models').Event
  , prenatalHistory = 'stats:prenatalHistory'
  , prenatalRecentHistory = 'stats:prenatalRecentHistory'
  , prenatalCheckInId
  , prenatalCheckOutId
  ;

// --------------------------------------------------------
// Do a one time load of EventType ids.
// --------------------------------------------------------
new EventTypes()
  .fetch()
  .then(function(list) {
    prenatalCheckInId = list.findWhere({name: 'prenatalCheckIn'}).get('id');
    prenatalCheckOutId = list.findWhere({name: 'prenatalCheckOut'}).get('id');
  });

// --------------------------------------------------------
// Update the cache of stats whenever any cluster worker
// (including this one) updates it.
// --------------------------------------------------------
process.on('message', function(msg) {
  // Prenatal long cache stats.
  if (msg && msg.cmd && msg.cmd === prenatalHistory) {
    longCache.set(prenatalHistory, msg.stats, function(err, success) {
      if (err) logError(err);
      if (! success) {
        logError('Failed to set ' + prenatalHistory);
      } else {
        logInfo('Saved ' + prenatalHistory + ' via event.');
      }
    });
  }
  if (msg && msg.cmd && msg.cmd === prenatalRecentHistory) {
    shortCache.set(prenatalRecentHistory, msg.stats, function(err, success) {
      if (err) logError(err);
      if (! success) {
        logError('Failed to set ' + prenatalRecentHistory);
      } else {
        logInfo('Saved ' + prenatalRecentHistory + ' via event.');
      }
    });
  }
});

/* --------------------------------------------------------
 * getRecentPrenatalHistory()
 *
 * Returns a map of stats about recent prenatal events such
 * as the number of exams this week.
 *
 * Uses shortCache so that the server is not needlessly hit.
 *
 * param      cb
 * return     map with stats
 * -------------------------------------------------------- */
var getRecentPrenatalHistory = function(cb) {
  var stats = {}
    ;
  shortCache.get(prenatalRecentHistory, function(err, recs) {
    if (err) logError(err);
    if (_.isEmpty(recs)) {
      var knex
        , sql = 'SELECT COUNT(*) AS cnt, DAYNAME(date) AS day ' +
        'FROM prenatalExam ' +
        'WHERE date > DATE_SUB(CURDATE(), INTERVAL ABS(1-DAYOFWEEK(CURDATE())) DAY) ' +
        'GROUP BY DAYOFWEEK(date)';
      knex = Bookshelf.DB.knex;
      knex
        .raw(sql, prenatalCheckOutId)
        .then(function(data) {
          stats.currWeek = data[0];
        })
        .then(function() {
          // Distribute results to all worker processes.
          process.send({cmd: prenatalRecentHistory, stats: stats});
          return cb(null, stats);
        });

    } else {
      // Return the cached results.
      return cb(null, recs[prenatalRecentHistory]);
    }
  });
};


/* --------------------------------------------------------
 * getPrenatalHistory()
 *
 * Returns a map of stats about prenatal events such as
 * number of prenatal exams in last day, week, month, etc.
 *
 * lastWeek, lastMonth, etc. means the prior week or month
 * respecting that the current week or month is not complete.
 * So it is not just anything between 14 and 7 days ago but
 * rather truly last week.
 *
 * Uses longCache so that the server is not needlessly hit.
 *
 * param      cb
 * return     map with stats
 * -------------------------------------------------------- */
var getPrenatalHistory = function(cb) {
  var stats = {}
    ;
  longCache.get(prenatalHistory, function(err, recs) {
    if (err) logError(err);
    if (_.isEmpty(recs)) {
      // Get the data from the database and update the cache.
      var knex = Bookshelf.DB.knex;
      // Last week (not this week).
      knex('prenatalExam')
        .count('* as lastWeek')
        .whereRaw('WEEK(date) = WEEK(CURDATE()) - 1')
        .then(function(data) {
          stats.lastWeek = data[0].lastWeek;
        })
        .then(function() {
          // Last month (not this month).
          return knex('prenatalExam')
            .count('* as lastMonth')
            .whereRaw('MONTH(date) = MONTH(CURDATE()) - 1');
        })
        .then(function(data) {
          stats.lastMonth = data[0].lastMonth;
        })
        .then(function() {
          // Last year (not this year).
          return knex('prenatalExam')
            .count('* as lastYear')
            .whereRaw('YEAR(date) = YEAR(CURDATE()) - 1');
        })
        .then(function(data) {
          stats.lastYear = data[0].lastYear;
        })
        .then(function() {
          // Distribute results to all workers, and return results to caller.
          // Stats are saved in the node-cache instance longCache when
          // the message is received by each worker, including this one.
          process.send({cmd: prenatalHistory, stats: stats});
          return cb(null, stats);
        });
    } else {
      // Return the cached results.
      return cb(null, recs[prenatalHistory]);
    }
  });
};

var home = function(req, res) {
  getPrenatalHistory(function(err, ph) {
    var prenatalHistoryData = {}
      ;
    prenatalHistoryData.data = [];
    prenatalHistoryData.data.push(['Last Week', ph.lastWeek]);
    prenatalHistoryData.data.push(['Last Month', ph.lastMonth]);
    prenatalHistoryData.data.push(['Last Year', ph.lastYear]);
    getRecentPrenatalHistory(function(err, rph) {
      // --------------------------------------------------------
      // Put the data in the format expected by the chart library.
      // --------------------------------------------------------
      var prenatalThisWeekData = {}
        ;
      prenatalThisWeekData.data = [];
      _.each(rph.currWeek, function(rec) {
        prenatalThisWeekData.data.push([rec.day, rec.cnt]);
      });
      res.render('home', {
        title: req.gettext('At a Glance')
        , user: req.session.user
        , prenatalThisWeekData: prenatalThisWeekData
        , prenatalThisWeekOptions: ''
        , prenatalHistoryData: prenatalHistoryData
        , prenatalHistoryOptions: ''
      });
    });
  });
};

var login = function(req, res) {
  var data = {
    title: req.gettext('Please log in')
    , message: req.session.messages
  };
  res.render('login', data);
};

var loginPost = function(req, res, next) {
  passport.authenticate('local', function(err, user, info) {
    if (err) {
      logError('err: %s', err);
      return next(err);
    }
    if (!user) {
      if (req.session) {
        req.session.messages =  [info.message];
      }
      return res.redirect(loginRoute);
    }
    req.logIn(user, function(err) {
      var options = {}
        ;
      if (err) { return next(err); }
      // --------------------------------------------------------
      // Store user information in the session sans sensitive info.
      // --------------------------------------------------------
      req.session.user = _.omit(user.toJSON(), 'password');;

      // --------------------------------------------------------
      // Record the event and redirect to the home page.
      // --------------------------------------------------------
      options.sid = req.sessionID;
      options.user_id = user.get('id');
      Event.loginEvent(options).then(function() {
        var pendingUrl = req.session.pendingUrl
          ;
        if (pendingUrl) {
          delete req.session.pendingUrl;
          req.session.save();
          res.redirect(pendingUrl);
        } else {
          return res.redirect('/');
        }
      });
    });
  })(req, res, next);
};

var logout = function(req, res) {
  var options = {}
    ;
  if (req.session.user && req.session.user.id) {
    options.sid = req.sessionID;
    options.user_id = req.session.user.id;
    Event.logoutEvent(options).then(function() {
      req.session.destroy(function(err) {
        res.redirect(loginRoute);
      });
    });
  } else {
    res.redirect(loginRoute);
  }
};



module.exports = {
  home: home
  , login: login
  , loginPost: loginPost
  , logout: logout
};


