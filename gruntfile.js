/* 
 * -------------------------------------------------------------------------------
 * grunt.js
 *
 * Grunt configuration file.
 * ------------------------------------------------------------------------------- 
 */

module.exports = function(grunt) {

  // --------------------------------------------------------
  // Initialization
  // --------------------------------------------------------
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json')
    , uglify: {
        options: {
          mangle: false
          , compress: false
          , banner: '/*!  <%= pkg.name %> ' +
                    '<%= grunt.template.today("yyyy-mm-dd HH:MM") %> */\n'
        }
        , footerTarget: {
            files: {
              'static/js/midwife-emr-footer.min.js': [
                'bower_components/jquery/dist/jquery.js'
                , 'bower_components/bootstrap/dist/js/bootstrap.js'
                , 'bower_components/underscore/underscore.js'
                , 'bower_components/moment/min/moment.min.js'
                , 'bower_components/flot/jquery.flot.js'
                , 'bower_components/flot/jquery.flot.categories.js'
                , 'bower_components/jquery.are-you-sure/jquery.are-you-sure.js'
                , 'client/js/responsive-tables.js'
                , 'client/js/jquery-ui.min.js'
                , 'client/js/midwife-emr.js'
                , 'client/js/midwife-emr-home.js'
                , 'client/js/priorityList.js'
              ]
            }
          }
        , footerTargetSPA: {
            files: {
              'static/js/midwife-emr-footer-spa.min.js': [
                'bower_components/angular/angular.js'
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
                , 'client/js/angular/components/historyControl/historyControl.js'
                , 'client/js/angular/components/patientWell/patientWell.js'
              ]
            }
          }
        , headerTarget: {
            files: {
              'static/js/midwife-emr-header.min.js': [
                'client/js/html5shiv.js'
                , 'client/js/respond.min.js'
              ]
            }
          }
      }

    , cssmin: {
        combine: {
          // Note: we are not doing the font-awesome stuff because the css uses
          // relative urls to the images, etc. in the font-awesome package.
          files: {
            'static/css/midwife-emr-combined.css': [
              'bower_components/bootstrap/dist/css/bootstrap.css'
              , 'client/css/sb-admin.css'
              , 'client/css/responsive-tables.css'
              , 'client/css/jquery-ui.min.css'
              , 'client/css/jquery-ui.structure.min.css'
              , 'client/css/jquery-ui.theme.min.css'
              , 'client/css/midwife-emr.css'
            ]
          }
        }
      }
    , ngtemplates: {
      views: {
        cwd: 'client/js',
        src: 'angular/views/*.html',
        dest: 'static/js/templates.js',
        options: {
          prefix: '/',
          module: 'midwifeEmr'
        }
      }
      , components: {
        cwd: 'client/js',
        src: 'angular/components/*/*.tmpl',
        dest: 'static/js/templates.js',
        options: {
          prefix: '/',
          module: 'midwifeEmr',
          append: true
        }
      }
    }
    , copy: {
        main: {
          // Copy the image files that are associated with the jquery-ui css files.
          expand: true
          , cwd: 'client/css/'
          , src: 'images/*'
          , dest: 'static/css/'
        }
        // ngtemplates above should pre-cache all of these templates for
        // the components as well as the views into templates.js which
        // is loaded into the $templateCache for us at application load.
        // So this is not properly necessary but is just a fallback so that
        // the templates are at least in the proper place on the server
        // should templateService need to resort to retrieving them from there.
        , angularComponents: {
            // The templates associated with the Angular components (directives).
            expand: true
            , cwd: 'client/js/angular/'
            , src: 'components/*/*.tmpl'
            , dest: 'static/angular/'
          }
        , angularViews: {
            // The templates associated with the views (Angular UI Router).
            expand: true
            , cwd: 'client/js/angular/'
            , src: 'views/*.html'
            , dest: 'static/angular/'
          }
      }
  });

  // --------------------------------------------------------
  // Load plugins.
  // --------------------------------------------------------
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-angular-templates');

  // --------------------------------------------------------
  // Define tasks.
  // --------------------------------------------------------
  grunt.registerTask('default', ['uglify', 'cssmin', 'ngtemplates', 'copy']);

};

