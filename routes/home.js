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
  , prenatalHistoryByWeek = 'stats:prenatalHistoryByWeek'
  , prenatalHistoryByMonth = 'stats:prenatalHistoryByMonth'
  , prenatalScheduled = 'stats:prenatalScheduled'
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

var getScheduledPrenatalExams = function(days, cb) {
  var stats = {}
    ;
  longCache.get(prenatalScheduled, function(err, recs) {
    if (err) logError(err);
    if (_.isEmpty(recs)) {
      var knex
        , sql = 'SELECT COUNT(*) AS cnt, DATE_FORMAT(returnDate, "%m-%d") AS scheduled ' +
          'FROM prenatalExam WHERE returnDate > CURDATE() ' +
          'AND returnDate < DATE_ADD(CURDATE(), INTERVAL ' + days + ' day) ' +
          'GROUP BY returnDate ORDER BY returnDate';
      knex = Bookshelf.DB.knex;
      knex
        .raw(sql)
        .then(function(data) {
          stats.prenatalScheduled = data[0];
        })
        .then(function() {
          // Distribute results to all worker processes.
          //
          // NOTE: no idea why I need this check but sometimes the
          // send() method is not there.
          if (process.send) process.send({cmd: prenatalScheduled, stats: stats});
          return cb(null, stats);
        });
    } else {
      return cb(null, recs[prenatalScheduled]);
    }
  });
};

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
        , sql = 'SELECT COUNT(*) AS cnt, SUBSTR(DAYNAME(date), 1, 3) AS day ' +
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
          //
          // NOTE: no idea why I need this check but sometimes the
          // send() method is not there.
          if (process.send) process.send({cmd: prenatalRecentHistory, stats: stats});
          return cb(null, stats);
        });

    } else {
      // Return the cached results.
      return cb(null, recs[prenatalRecentHistory]);
    }
  });
};


/* --------------------------------------------------------
 * getPrenatalHistoryByWeek()
 *
 * Return the number of prenatal exams conducted by week
 * going back the specified number of weeks from the present.
 *
 * param      numWeeks
 * param      cb
 * return     undefined
 * -------------------------------------------------------- */
var getPrenatalHistoryByWeek = function(numWeeks, cb) {
  var stats = {}
    , cacheKey = prenatalHistoryByWeek + ':' + numWeeks
    ;
  longCache.get(cacheKey, function(err, recs) {
    if (err) logError(err);
    if (_.isEmpty(recs)) {
      var knex
        , sql = 'SELECT COUNT(*) AS cnt, ' +
        'CONCAT(SUBSTR(YEAR(date), 3), "-", LPAD(WEEK(date, 2), 2, "0")) AS yearweek ' +
        'FROM prenatalExam ' +
        'WHERE date > DATE_SUB(CURDATE(), INTERVAL ? WEEK) ' +
        'GROUP BY CONCAT(SUBSTR(YEAR(date), 3), "-", LPAD(WEEK(date, 2), 2, "0"))';
      knex = Bookshelf.DB.knex;
      knex
        .raw(sql, numWeeks)
        .then(function(data) {
          stats.historyByWeek = data[0];
        })
        .then(function() {
          // Distribute results to all worker processes.
          //
          // NOTE: no idea why I need this check but sometimes the
          // send() method is not there.
          if (process.send) process.send({cmd: cacheKey, stats: stats});
          return cb(null, stats);
        });

    } else {
      // Return the cached results.
      return cb(null, recs[cacheKey]);
    }
  });
};

/* --------------------------------------------------------
 * getPrenatalHistoryByMonth()
 *
 * Return the count of prenatal exams by months for the
 * past number of months specified.
 *
 * param      numMonths
 * param      cb
 * return     undefined
 * -------------------------------------------------------- */
var getPrenatalHistoryByMonth = function(numMonths, cb) {
  var stats = []
    , cacheKey = prenatalHistoryByMonth + ':' + numMonths
    ;
  longCache.get(cacheKey, function(err, recs) {
    var knex
      , sql
      ;
    sql = 'SELECT COUNT(*) AS cnt, SUBSTR(MONTHNAME(date), 1, 3) AS month ' +
          'FROM prenatalExam ' +
          'WHERE date > DATE_SUB(CURDATE(), INTERVAL ? MONTH) ' +
          'GROUP BY MONTHNAME(date) ' +
          'ORDER BY date';
    if (err) logError(err);
    if (_.isEmpty(recs)) {
      knex = Bookshelf.DB.knex;
      knex
        .raw(sql, numMonths)
        .then(function(data) {
          stats.historyByMonth = data[0];
        })
        .then(function() {
          // Distribute results to all worker processes.
          //
          // NOTE: no idea why I need this check but sometimes the
          // send() method is not there.
          if (process.send) process.send({cmd: cacheKey, stats: stats});
          return cb(null, stats);
        });
    } else {
      // Return the cached results.
      return cb(null, recs[cacheKey]);
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
          //
          // NOTE: no idea why I need this check but sometimes the
          // send() method is not there.
          if (process.send) process.send({cmd: prenatalHistory, stats: stats});
          return cb(null, stats);
        });
    } else {
      // Return the cached results.
      return cb(null, recs[prenatalHistory]);
    }
  });
};

/* --------------------------------------------------------
 * home()
 *
 * TODO: get number of months or days from config file.
 *
 * Render the home page which has charts and stats on it.
 * -------------------------------------------------------- */
var home = function(req, res) {
  // --------------------------------------------------------
  // Get the number of prenatal exams performed in the last year.
  // --------------------------------------------------------
  getPrenatalHistoryByMonth(12, function(err, hbm) {
    var prenatalHistoryByMonthData = {};
    prenatalHistoryByMonthData.data = [];
    _.each(hbm.historyByMonth, function(rec) {
      prenatalHistoryByMonthData.data.push([rec.month, rec.cnt]);
    });

    // --------------------------------------------------------
    // Get the scheduled prenatal exams for the next 30 days.
    // --------------------------------------------------------
    getScheduledPrenatalExams(30, function(err, spe) {
      var prenatalScheduled = {};
      prenatalScheduled.data = [];
      _.each(spe.prenatalScheduled, function(sch) {
        prenatalScheduled.data.push([sch.scheduled, sch.cnt]);
      });

      res.render('home', {
        title: req.gettext('At a Glance')
        , user: req.session.user
        , prenatalScheduled: prenatalScheduled
        , prenatalScheduledOptions: ''
        , prenatalHistoryByMonthData: prenatalHistoryByMonthData
        , prenatalHistoryByWeekOptions: ''
      });
    });
  });
};

/* --------------------------------------------------------
 * login()
 *
 * Render the login page.
 * -------------------------------------------------------- */
var login = function(req, res) {
  var data = {
    title: req.gettext('Please log in')
    , message: req.session.messages
    , messages: req.flash()
    , siteTitle: cfg.site.title
  };
  res.render('login', data);
};

/* --------------------------------------------------------
 * loginPost()
 *
 * Process the user's authentication attempt from the login
 * page.
 * -------------------------------------------------------- */
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
      req.session.user = _.omit(user.toJSON(), 'password');

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

/* --------------------------------------------------------
 * logout()
 *
 * Logs the user out of the system by regenerating the
 * session object and rendering the logout page, which is
 * used to "park" the browser until the user is ready to
 * login again. This helps the CSRF token on the login
 * page from expiring while the user is logged out.
 *
 * Note: this is meant to be used with the clearRoleInfo()
 * method that clears sensitive role information from the
 * data that is made available to the template system.
 * -------------------------------------------------------- */
var logout = function(req, res) {
  var options = {}
    , data = {
        title: 'You are now logged out'
    }
    ;
  if (req.session.user && req.session.user.id) {
    options.sid = req.sessionID;
    options.user_id = req.session.user.id;
    Event.logoutEvent(options).then(function() {
      req.session.regenerate(function(err) {
        res.render('logout', data);
      });
    });
  } else {
    res.render('logout', data);
  }
};



module.exports = {
  home: home
  , login: login
  , loginPost: loginPost
  , logout: logout
};


