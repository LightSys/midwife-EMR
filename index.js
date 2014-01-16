/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * -------------------------------------------------------------------------------
 */

var express = require('express')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , cons = require('consolidate')
  , app = express()
  , SessionStore = require('connect-mysql')(express)
  , cfg = require('./config')
  , port = 3000
  , path = require('path')
  , loginRoute = '/login'
  , logoutRoute = '/logout'
  //, users = []    // mock for testing
  , User = require('./models').User
  ;

// --------------------------------------------------------
// These next three calls are per the example application at:
// https://github.com/jaredhanson/passport-local/blob/master/examples/express3-no-connect-flash/app.js
// --------------------------------------------------------
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  findById(id, function (err, user) {
    done(err, user);
  });
});

passport.use(new LocalStrategy(
  function(username, password, done) {
    //Find the user by username.  If there is no user with the given
    //username, or the password is not correct, set the user to `false` to
    //indicate failure and set a flash message.  Otherwise, return the
    //authenticated `user`.
    findByUsername(username, function(err, user) {
      if (err) { return done(err); }
      if (!user) { return done(null, false, { message: 'Unknown user ' + username }); }
      user.checkPassword(password, function(err, same) {
        if (err) return done(err);
        if (same) {
          return done(null, user);
        } else {
          return done(null, false, {message: 'Invalid password'});
        }
      });
    });
  }
));

// --------------------------------------------------------
// All configurations.
// --------------------------------------------------------
app.use(express.static('bower_components'));
app.use(express.static('static'));
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.cookieParser(cfg.cookie.secret));
app.use(express.session({
  secret: cfg.session.secret
  , cookie: {maxAge: cfg.cookie.maxAge}
  , store: new SessionStore(cfg.session)
}));
app.use(express.bodyParser());
app.use(passport.initialize());
app.use(passport.session());

// --------------------------------------------------------
// Protect against cross site request forgeries.
// See: http://dailyjs.com/2012/09/13/express-3-csrf-tutorial/
// --------------------------------------------------------
app.use(express.csrf());
function csrf(req, res, next) {
  console.log('csrf() has been called.');
  res.locals.token = req.csrfToken();
  next();
}

// --------------------------------------------------------
// The server presents a login page to establish authenticated
// sessions with the clients before allowing the client directories
// to be loaded. Uses CSRF protection.
// --------------------------------------------------------
//app.set('view engine', 'ejs');
app.engine('jade', cons.jade);
app.set('view engine', 'jade');
app.set('views', path.join(__dirname,'views'));


// --------------------------------------------------------
// Login
// --------------------------------------------------------
app.get(loginRoute, csrf, function(req, res) {
  var data = {
    title: 'Please log in'
    , message: req.session.messages
  };
  res.render('login', data);
});

// --------------------------------------------------------
// Handle a login attempt.
// --------------------------------------------------------
app.post(loginRoute, function(req, res, next) {
  passport.authenticate('local', function(err, user, info) {
    if (err) {
      console.log('err: %s', err);
      return next(err);
    }
    if (!user) {
      if (req.session) {
        req.session.messages =  [info.message];
      }
      return res.redirect(loginRoute);
    }
    req.logIn(user, function(err) {
      if (err) { return next(err); }
      console.log('logIn() success');
      req.session.userid = user.id;
      return res.redirect('/');
    });
  })(req, res, next);
});

app.use(app.router);

// development only
app.configure('development', function() {
  console.log('DEVELOPMENT mode');
  app.use(express.errorHandler());
});

app.configure('production', function() {
  console.log('PRODUCTION mode');
});

// --------------------------------------------------------
// Everything below this point requires authentication.
// --------------------------------------------------------
app.use(ensureAuthenticated);

app.get(logoutRoute, function(req, res) {
  req.session.destroy(function(err) {
    res.redirect(loginRoute);
  });
});

app.get('/', function(req, res) {
  res.render('content', {
    title: 'Testing'
    , user: {
      id: req.session.userid
    }
  });
});

app.listen(port);
console.log('Server listening on port ' + port);


// --------------------------------------------------------
// Users for testing only.
// --------------------------------------------------------
//users.push({username: 'user1', password: 'testuser1', id: 1});
//users.push({username: 'user2', password: 'testuser2', id: 2});
//users.push({username: 'user3', password: 'testuser3', id: 3});
//users.push({username: 'user4', password: 'testuser4', id: 4});

/* --------------------------------------------------------
 * findById()
 *
 * param       id
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
function findById(id, cb) {
  console.log('findById()');
  User.forge({id: id})
    .fetch()
    .then(function(u) {
      if (! u) return cb(new Error('User ' + id + ' does not exist.'));
      // TODO: security issues with password hash, etc.
      return cb(null, u.toJSON());
    });
}

/* --------------------------------------------------------
 * findByUsername()
 *
 * param       username
 * param       cb
 * return      undefined
 * -------------------------------------------------------- */
function findByUsername(username, cb) {
  console.log('findByUsername()');
  User.forge({username: username})
    .fetch()
    .then(function(u) {
      if (! u) return cb(new Error('User ' + username + ' does not exist.'));
      // TODO: security issues with password hash, etc.
      return cb(null, u);
    });
}


/* --------------------------------------------------------
 * ensureAuthenticated()
 *
 * param       req
 * param       res
 * param       next
 * return      undefined
 * -------------------------------------------------------- */
function ensureAuthenticated(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  console.log('Redirecting to login');
  res.redirect(loginRoute);
}

