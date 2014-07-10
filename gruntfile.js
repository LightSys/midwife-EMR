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
              'static/js/mercy-footer.min.js': [
                'bower_components/jquery/dist/jquery.js'
                , 'bower_components/bootstrap/dist/js/bootstrap.js'
                , 'bower_components/underscore/underscore.js'
                , 'bower_components/moment/min/moment.min.js'
                , 'client/js/responsive-tables.js'
                , 'client/js/mercy.js'
                , 'client/js/priorityList.js'
              ]
            }
          }
        , headerTarget: {
            files: {
              'static/js/mercy-header.min.js': [
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
            'static/css/mercy-combined.css': [
              'bower_components/bootstrap/dist/css/bootstrap.css'
              , 'client/css/sb-admin.css'
              , 'client/css/responsive-tables.css'
              , 'client/css/mercy.css'
            ]
          }
        }
      }
  });

  // --------------------------------------------------------
  // Load plugins.
  // --------------------------------------------------------
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');


  // --------------------------------------------------------
  // Define tasks.
  // --------------------------------------------------------
  grunt.registerTask('default', ['uglify', 'cssmin']);

};

