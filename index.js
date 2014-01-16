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
  , User = require('./models').User
  , search = require('./routes').search
  , home = require('./routes').home
  , common = []
  ;

// --------------------------------------------------------
// These next three calls are per the example application at:
// https://github.com/jaredhanson/passport-local/blob/master/examples/express3-no-connect-flash/app.js
// --------------------------------------------------------
passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function (err, user) {
    done(err, user);
  });
});

passport.use(new LocalStrategy(
  function(username, password, done) {
    //Find the user by username.  If there is no user with the given
    //username, or the password is not correct, set the user to `false` to
    //indicate failure and set a flash message.  Otherwise, return the
    //authenticated `user`.
    User.findByUsername(username, function(err, user) {
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
app.engine('jade', cons.jade);
app.set('view engine', 'jade');
app.set('views', path.join(__dirname,'views'));
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

app.locals.siteTitle = cfg.site.title;

// --------------------------------------------------------
// Protect against cross site request forgeries.
// See: http://dailyjs.com/2012/09/13/express-3-csrf-tutorial/
// --------------------------------------------------------
app.use(express.csrf());
function csrf(req, res, next) {
  res.locals.token = req.csrfToken();
  next();
}

app.use(app.router);

// --------------------------------------------------------
// Development configuration
// --------------------------------------------------------
app.configure('development', function() {
  console.log('DEVELOPMENT mode');
  app.use(express.errorHandler());
});

// --------------------------------------------------------
// Production configuration
// --------------------------------------------------------
app.configure('production', function() {
  console.log('PRODUCTION mode');
});

// ========================================================
// ========================================================
// Routes
// ========================================================
// ========================================================

// --------------------------------------------------------
// Group of methods that are commonly needed for 
// many requests.
// --------------------------------------------------------
common.push(auth);

// --------------------------------------------------------
// Login and logout
// --------------------------------------------------------
app.get(loginRoute, csrf, home.login);
app.post(loginRoute, home.loginPost);
app.get(logoutRoute, common, home.logout);

// --------------------------------------------------------
// Home
// --------------------------------------------------------
app.get('/', common, home.home);

// --------------------------------------------------------
// Search
// --------------------------------------------------------
app.get('/search', common, csrf, search.view);
app.post('/search', common, csrf, search.execute);


// --------------------------------------------------------
// Start the server.
// --------------------------------------------------------
app.listen(port);
console.log('Server listening on port ' + port);

/* --------------------------------------------------------
 * auth()
 *
 * param       req
 * param       res
 * param       next
 * return      undefined
 * -------------------------------------------------------- */
function auth(req, res, next) {
  if (req.isAuthenticated()) { return next(); }
  console.log('Redirecting to login');
  res.redirect(loginRoute);
}

