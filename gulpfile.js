/*
 * -------------------------------------------------------------------------------
 * gulpfile.js
 *
 * Automated tasks for Midwife-EMR.
 *
 * Borrowed ideas from:
 * - https://github.com/webpack/webpack-with-common-libs/blob/master/gulpfile.js
 * -------------------------------------------------------------------------------
 */
var gulp = require('gulp');
var mocha = require('gulp-mocha');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var ngAnnotate = require('gulp-ng-annotate');
var minifyCss = require('gulp-minify-css');
var templateCache = require('gulp-angular-templatecache');
var Promise = require('bluebird');
var del = require('del');
var jshint = require('gulp-jshint');
var webpack = require('webpack');
var gutil = require('gulp-util');
var webpackConfig = require('./webpack.config.js');

// --------------------------------------------------------
// Global configuration options for various gulp packages.
// --------------------------------------------------------
var cfg = {
  uglify: {
    mangle: false,
    compress: true
  },
  ngAnnotate: {},
  minifyCss: {
    advanced: false,
    agressiveMerging: false,
    roundingPrecision: -1
  },
  templateCacheViews: {
    root: '/angular/views/',
    module: 'midwifeEmr',
    filename: 'templateViews.js',
    moduleSystem: 'IIFE'
  },
  templateCacheComponents: {
    root: '/angular/components/',
    module: 'midwifeEmr',
    filename: 'templateComponents.js',
    moduleSystem: 'IIFE'
  }
};

// --------------------------------------------------------
// Webpack for development.
// --------------------------------------------------------
var devConfig = Object.create(webpackConfig);
devConfig.devtool = 'sourcemap';
devConfig.debug = true;
var devCompiler = webpack(devConfig);

gulp.task('webpack:build-dev', function(cb) {
  if (process.env['WEBPACK_WATCH']) {
    // E.g.:  WEBPACK_WATCH=1 gulp webpack:build-dev
    devCompiler.watch({}, function(err, stats) {
      if (err) throw new gutil.PluginError('webpack:build-dev', err);
      gutil.log('[webpack:build-dev]', stats.toString({colors: true}));
    });
  } else {
    devCompiler.run(function(err, stats) {
      if (err) throw new gutil.PluginError('webpack:build-dev', err);
      gutil.log('[webpack:build-dev]', stats.toString({colors: true}));
      cb();
    });
  }
});

// --------------------------------------------------------
// test - run Mocha tests.
// --------------------------------------------------------
gulp.task('test', function() {
  var origEnv = process.env.NODE_ENV;
  process.env.NODE_ENV = 'test';
  return gulp
    .src(['test/test.*.js'], {read: false})
    .pipe(mocha({
      reporter: 'spec',
      require: ['should']
    }))
    .once('error', function() {
      process.exit(1);
    })
    .once('end', function() {
      process.env.NODE_ENV = origEnv;
      process.exit();
    });
});

// --------------------------------------------------------
// Concat and uglify the js to include in the header.
// --------------------------------------------------------
gulp.task('uglify-header', function() {
  return gulp
    .src(['client/js/html5shiv.js'
        , 'client/js/respond.min.js'
      ])
    .pipe(concat('midwife-emr-header.min.js'))
    .pipe(uglify(cfg.uglify))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Concat and uglify the js to include in the header for
// Angular2 app.
// --------------------------------------------------------
gulp.task('uglify-header-ang2', function() {
  return gulp
    .src(['node_modules/es6-shim/es6-shim.js'])
    .pipe(concat('midwife-emr-header-ang2.min.js'))
    .pipe(uglify(cfg.uglify))
    .pipe(gulp.dest('static/js/'));
});


// --------------------------------------------------------
// Concat and uglify the js to include in the footer.
// Note: source order is important.
// --------------------------------------------------------
gulp.task('uglify-footer', function() {
  return gulp
    .src(['bower_components/jquery/dist/jquery.js'
          , 'bower_components/bootstrap/dist/js/bootstrap.js'
          , 'bower_components/underscore/underscore.js'
          , 'bower_components/moment/min/moment.min.js'
          , 'bower_components/flot/jquery.flot.js'
          , 'bower_components/flot/jquery.flot.categories.js'
          , 'bower_components/jquery.are-you-sure/jquery.are-you-sure.js'
          , 'node_modules/falcor/dist/falcor.all.js'
          , 'client/js/responsive-tables.js'
          , 'client/js/jquery-ui.min.js'
          , 'client/js/midwife-emr.js'
          , 'client/js/midwife-emr-home.js'
          , 'client/js/priorityList.js'
          , 'client/js/midwife-emr-sockets.js'
      ])
    .pipe(concat('midwife-emr-footer.min.js'))
    .pipe(uglify(cfg.uglify))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Concat and uglify the js to include in the footer for
// the SPA portion of the application.
// Note: source order is important.
// --------------------------------------------------------
gulp.task('uglify-footer-spa', function() {
  return gulp
    .src(['bower_components/angular/angular.js'
        , 'bower_components/angular-moment/angular-moment.js'
        , 'bower_components/angular-ui-router/release/angular-ui-router.js'
        , 'bower_components/ui-router-extras/release/modular/ct-ui-router-extras.core.js'
        , 'bower_components/ui-router-extras/release/modular/ct-ui-router-extras.future.js'
        , 'client/js/angular/app.js'
        , 'client/js/angular/router.js'
        , 'client/js/angular/services/minPubSubNg/minPubSubNg.js'
        , 'client/js/angular/services/historyService/historyService.js'
        , 'client/js/angular/services/changeRoutingService/changeRoutingService.js'
        , 'client/js/angular/services/templateService/templateService.js'
        , 'client/js/angular/services/loggingService/loggingService.js'
        , 'client/js/angular/components/historyControl/historyControl.js'
        , 'client/js/angular/components/patientWell/patientWell.js'
      ])
    .pipe(ngAnnotate(cfg.ngAnnotate))
    .pipe(concat('midwife-emr-footer-spa.min.js'))
    .pipe(uglify(cfg.uglify))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Handle the Angular view templates by enabling them to be
// loaded into $templateCache.
// --------------------------------------------------------
gulp.task('templateCache-views', function() {
  return gulp
    .src([
      'client/js/angular/views/*.html',
    ])
    .pipe(templateCache(cfg.templateCacheViews))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Handle the Angular component templates by enabling them
// to be loaded into $templateCache.
// --------------------------------------------------------
gulp.task('templateCache-components', function() {
  return gulp
    .src([
      'client/js/angular/components/**/*.tmpl',
    ])
    .pipe(templateCache(cfg.templateCacheComponents))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Concat both template files into one.
// TODO: refactor these template cache tasks.
// --------------------------------------------------------
gulp.task('templateCache',
  ['templateCache-views', 'templateCache-components'], function() {
  return gulp
    .src(['static/js/' + cfg.templateCacheViews.filename,
          'static/js/' + cfg.templateCacheComponents.filename])
    .pipe(concat('templates.js'))
    .pipe(gulp.dest('static/js/'));
});

// --------------------------------------------------------
// Clean up temporary template cache files.
// --------------------------------------------------------
gulp.task('cleanupTemplateCache', ['templateCache'], function() {
  return del(['static/js/' + cfg.templateCacheViews.filename,
              'static/js/' + cfg.templateCacheComponents.filename]);
});

// --------------------------------------------------------
// Concat and minimize the CSS.
// --------------------------------------------------------
gulp.task('css', function() {
  return gulp
    .src(['bower_components/bootstrap/dist/css/bootstrap.css'
        , 'client/css/sb-admin.css'
        , 'client/css/responsive-tables.css'
        , 'client/css/jquery-ui.min.css'
        , 'client/css/jquery-ui.structure.min.css'
        , 'client/css/jquery-ui.theme.min.css'
        , 'client/css/midwife-emr.css'
      ])
    .pipe(minifyCss(cfg.minifyCss))
    .pipe(concat('midwife-emr-combined.css'))
    .pipe(gulp.dest('static/css/'));
});


// --------------------------------------------------------
// Copy the images required into place.
// --------------------------------------------------------
gulp.task('images', function() {
  return gulp
    .src('client/css/images/*')
    .pipe(gulp.dest('static/css/images/'));
});

// --------------------------------------------------------
// Copy the favicon to the required place.
// --------------------------------------------------------
gulp.task('favicon', function() {
  return gulp
    .src('client/favicon.ico')
    .pipe(gulp.dest('static/'));
});

// --------------------------------------------------------
// Copy the font-awesome into place.
// --------------------------------------------------------
gulp.task('font-awesome', function() {
  return gulp
    .src('client/font-awesome/**/*')
    .pipe(gulp.dest('static/font-awesome/'));
});

// --------------------------------------------------------
// JSHint
// --------------------------------------------------------
gulp.task('jshint', function() {
  return gulp
    .src(['client/js/midwife-emr-home.js',
          'client/js/midwife-emr.js',
          'client/js/priorityList.js',
          'client/js/angular/**/*.js'])
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

// --------------------------------------------------------
// The default tasks.
// --------------------------------------------------------
gulp.task('default', [
  'uglify-header',
  'uglify-header-ang2',
  'uglify-footer',
  'uglify-footer-spa',
  'templateCache',
  'css',
  'images',
  'favicon',
  'font-awesome',
  'cleanupTemplateCache',
  'webpack:build-dev'
]);


