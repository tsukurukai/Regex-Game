module.exports = (grunt) ->
  grunt.initConfig
    requirejs:
      all:
        options:
          mainConfigFile: 'assets/js/require.config.js'
          baseUrl: './assets/js'
          paths:
            requireLib: 'lib/require'
          include: ['requireLib']
          name: 'regexgame'
          out: 'public/js/main.min.js'

  grunt.loadNpmTasks "grunt-contrib-requirejs"
