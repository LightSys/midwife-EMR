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
  });

  // --------------------------------------------------------
  // Load plugins.
  // --------------------------------------------------------
  grunt.loadNpmTasks('grunt-contrib-uglify');


  // --------------------------------------------------------
  // Define tasks.
  // --------------------------------------------------------
  grunt.registerTask('default', ['uglify']);

};

