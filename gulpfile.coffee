gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'


gulp.task 'lint', ->
  gulp
    .src [
      './apps/**/*.coffee'
      './conf/**/*.coffee'
      './env/**/*.coffee'
      './lib/**/*.coffee'
      './test/**/*.coffee'
    ]
    .pipe coffeelint()
    .pipe coffeelint.reporter()
