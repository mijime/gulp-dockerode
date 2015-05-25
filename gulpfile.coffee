gulp = require "gulp"
$ = do require "gulp-load-plugins"

gulp.task "default", ["js"]

gulp.task "js", ->
  gulp.src "src/**/*.coffee"
    .pipe $.coffee bare: true
    .pipe gulp.dest "."
