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

    karma:
      unit:
        configFile: 'karma.conf.js'

    watch:
      requirejs:
        files: ['assets/**/*{js,css}']
        tasks: 'requirejs:all'

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-karma"
