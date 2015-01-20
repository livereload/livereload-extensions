module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    coffee: {
      src: {
        expand: true,
        cwd: 'src',
        src: '**/*.coffee',
        dest: 'lib',
        ext: '.js'
      }
    },

    browserify: {
      safari: {
        files: {
          'LiveReload.safariextension/global.js': ['lib/safari/global.js'],
          'LiveReload.safariextension/injected.js': ['lib/safari/injected.js']
        }
      },
      chrome: {
        files: {
          'Chrome/LiveReload/global.js': ['lib/chrome/global.js'],
          'Chrome/LiveReload/injected.js': ['lib/chrome/injected.js'],
          'Chrome/LiveReload/devtools.js': ['lib/chrome/devtools.js']
        }
      },
      firefox: {
        files: {
          'Firefox/content/firefox.js': ['lib/firefox/firefox.js']
        }
      }
    },

    compress: {
      options: {
        pretty: true,
        level: 9,
      },
      chrome: {
        options: {
          archive: 'dist/<%= pkg.version %>/LiveReload-<%= pkg.version %>-ChromeWebStore.zip'
        },
        files: [
          { expand: true, cwd: 'Chrome/LiveReload', src: ['**.{json,js,html,png}'], dest: 'LiveReload/' }
        ]
      },
      firefox: {
        options: {
          archive: 'dist/<%= pkg.version %>/LiveReload-<%= pkg.version %>.xpi',
          mode: 'zip'
        },
        files: [
          { expand: true, cwd: 'Firefox', src: ['**/*.{js,xul,manifest,rdf,png}'], dest: '/' }
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-compress');

  grunt.registerTask('build', ['coffee', 'browserify']);
  grunt.registerTask('default', ['build']);

  grunt.registerTask('chrome', ['coffee', 'browserify:chrome', 'compress:chrome']);
  grunt.registerTask('firefox', ['coffee', 'browserify:firefox', 'compress:firefox']);
  grunt.registerTask('all', ['chrome', 'firefox']);

};
