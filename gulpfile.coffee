gulp = require 'gulp'
coffeelint = require 'gulp-coffeelint'


gulp.task 'lint', ->
  gulp
    .src [
      './apps/**/*.coffee'
    ]
    .pipe coffeelint()
    .pipe coffeelint.reporter()
