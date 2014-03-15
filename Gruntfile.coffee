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

    concat:
      options:
        separator: ';'

      dist:
        src: ['assets/js/*.js']
        dest: 'public/js/main.js'

    karma:
      unit:
        configFile: 'karma.conf.js'

    watch:
      requirejs:
        files: ['assets/**/*{js,css}']
        tasks: 'concat:dist'

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-karma"
