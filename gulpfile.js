var gulp = require('gulp'),
    jshint = require('gulp-jshint'),
    uglify = require('gulp-uglify'),
    concat = require('gulp-concat');
    sass = require('gulp-sass');
    cssmin = require('gulp-cssmin');
    rename = require('gulp-rename');
    del = require('del');

gulp.task('minify', function () {
    return gulp.src('assets/js/*.js')
        .pipe(jshint())
        .pipe(jshint.reporter('default'))
        .pipe(uglify())
        .pipe(concat('app.min.js'))
        .pipe(gulp.dest('build/js'));
});

gulp.task('styles', function () {
    return gulp.src('assets/sass/*.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(cssmin())
        .pipe(rename({ suffix: '.min' }))
        .pipe(gulp.dest('build/css'));
});

gulp.task('clean', function() {
    return del([
        'build/css','build/js'
    ]);
});

gulp.task('default', gulp.series(['clean', 'styles', 'minify']));