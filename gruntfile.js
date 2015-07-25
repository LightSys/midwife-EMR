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
                , 'bower_components/angular/angular.js'
                , 'bower_components/angular-moment/angular-moment.js'
                , 'bower_components/angular-ui-router/release/angular-ui-router.js'
                , 'client/js/responsive-tables.js'
                , 'client/js/jquery-ui.min.js'
                , 'client/js/midwife-emr.js'
                , 'client/js/midwife-emr-home.js'
                , 'client/js/priorityList.js'
                , 'client/js/angular/app.js'
                , 'client/js/angular/router.js'
                , 'client/js/angular/services/historyService/historyService.js'
                , 'client/js/angular/services/changeRoutingService/changeRoutingService.js'
                , 'client/js/angular/services/templateService/templateService.js'
                , 'client/js/angular/services/minPubSubNg/minPubSubNg.js'
                , 'client/js/angular/components/historyControl/historyControl.js'
                , 'client/js/angular/components/patientWell/patientWell.js'
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
    , copy: {
        main: {
          // Copy the image files that are associated with the jquery-ui css files.
          expand: true
          , cwd: 'client/css/'
          , src: 'images/*'
          , dest: 'static/css/'
        }
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

  // --------------------------------------------------------
  // Define tasks.
  // --------------------------------------------------------
  grunt.registerTask('default', ['uglify', 'cssmin', 'copy']);

};

