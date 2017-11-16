module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    browserify: {
      options: {
        transform: ['coffeeify'],
        browserifyOptions: {
          extensions: ['.coffee']
        }
      },
      safari: {
        files: {
          'LiveReload.safariextension/global.js': ['src/safari/global.coffee'],
          'LiveReload.safariextension/injected.js': ['src/safari/injected.coffee'],
          'LiveReload.safariextension/livereload.js': ['src/livereload-js.coffee']
        }
      },
      chrome: {
        files: {
          'Chrome/LiveReload/global.js': ['src/chrome/global.coffee'],
          'Chrome/LiveReload/injected.js': ['src/chrome/injected.coffee'],
          'Chrome/LiveReload/devtools.js': ['src/chrome/devtools.coffee'],
          'Chrome/LiveReload/livereload.js': ['src/livereload-js.coffee']
        }
      },
      firefox: {
        files: {
          'Firefox/LiveReload/global.js': ['src/firefox/global.coffee'],
          'Firefox/LiveReload/injected.js': ['src/firefox/injected.coffee'],
          'Firefox/LiveReload/devtools.js': ['src/firefox/devtools.coffee'],
          'Firefox/LiveReload/livereload.js': ['src/livereload-js.coffee']
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
          archive: 'dist/<%= pkg.version %>/LiveReload-<%= pkg.version %>-Firefox.zip'
        },
        files: [
          { expand: true, cwd: 'Firefox/LiveReload', src: ['**.{json,js,html,png}'], dest: './' }
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-compress');

  grunt.registerTask('build', ['browserify']);
  grunt.registerTask('default', ['build']);

  grunt.registerTask('chrome', ['browserify:chrome', 'compress:chrome']);
  grunt.registerTask('firefox', ['browserify:firefox', 'compress:firefox']);
  grunt.registerTask('all', ['chrome', 'firefox']);

};
