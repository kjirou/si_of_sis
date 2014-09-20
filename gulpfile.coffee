gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'


gulp.task 'lint', ->
  gulp
    .src [
      './apps/**/*.coffee'
      './config/**/*.coffee'
      './test/**/*.coffee'
    ]
    .pipe coffeelint()
    .pipe coffeelint.reporter()
