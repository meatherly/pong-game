# gulp guide: http://vincent.is/introducing-people-to-gulp/

gulp = require 'gulp'
gutil = require 'gulp-util'

sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
clean = require 'gulp-clean'
runSequence = require 'run-sequence'

sources =
  sass: 'source/sass/**/*.scss'
  html: 'source/index.html'
  coffee: 'source/coffee/app.coffee'
  jsLibs: 'source/libs/*.js'

destinations =
  css: 'app/css'
  html: 'app/'
  js: 'app/js'
  jsLibs: 'app/js/libs'

gulp.task 'style', ->
  gulp.src(sources.sass) # we defined that at the top of the file
  .pipe(sass({outputStyle: 'compressed', errLogToConsole: true}))
  .pipe(concat('style.css'))
  .pipe(gulp.dest(destinations.css))

gulp.task 'html', ->
  gulp.src(sources.html)
  .pipe(gulp.dest(destinations.html))

gulp.task 'jsLibs', ->
  gulp.src(sources.jsLibs)
  .pipe(gulp.dest(destinations.jsLibs))

gulp.task 'src', ->
  gulp.src(sources.coffee)
  .pipe(coffee({bare: true}).on('error', gutil.log))
  .pipe(concat('app.js'))
  .pipe(gulp.dest(destinations.js))

gulp.task 'watch', ->
  gulp.watch sources.sass, ['style']
  gulp.watch sources.coffee, ['src']
  gulp.watch sources.html, ['html']
  gulp.watch sources.jsLibs, ['jsLibs']

gulp.task 'clean', ->
  gulp.src(['app/'], {read: false}).pipe(clean())

gulp.task 'build', ->
  runSequence 'clean', ['style', 'src', 'jsLibs', 'html']

gulp.task 'default', ['build', 'watch']
