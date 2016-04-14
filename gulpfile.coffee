# utils
#path = require "path"
#args = (require "yargs").argv


# gulp
gulp = require "gulp"
argv = (require "yargs").argv
connect = require 'gulp-connect'

console.log argv
params =
    server: argv.server || 8080
    liveReload: argv.liveReload || 8081
    pretty: argv.pretty || true
    minify: argv.minify || false

gulp.task "build", ->

gulp.task "devel", ->
    connect.server
        root: 'public'
        port: params.server
        livereload:
            port: params.liveReload

gulp.task "default", ["build"]

###
# gulp modules
jade = require "gulp-jade"
stylus = require "gulp-stylus"
#rename = require "gulp-rename"
#mocha = require "gulp-mocha"
#plumber = require "gulp-plumber"
connect = require "gulp-connect"
coffeeify = require "gulp-coffeeify"

# other modules for gulp tasks
browserify = require "browserify"
transform = require "vinyl-transform"
nib = require "nib"
nsg = require "node-sprite-generator"

# PARAMS
SRC_ROOT = "src"
DEBUG_ROOT = "debug"
RELEASE_ROOT = "release"
CONNECT_SETTING =
    root: DEBUG_ROOT
    host: "0.0.0.0"
    port: 9000
STYLUS_DEF = require "./stylus-def"

coffeeify = ->
    transform (filename) ->
        browserify filename,
            extensions: [".coffee"]
        .transform {}, "coffeeify"
        .bundle()

getPaths = (src_root, dest_root) ->
    src:
        jade: path.join src_root, "jade"
        stylus: path.join src_root, "stylus"
        coffee: path.join src_root, "coffee"
        img: path.join src_root, "img"
    dest:
        html: dest_root
        css: path.join dest_root, "css"
        js: path.join dest_root, "js"
        img: path.join dest_root, "img"

paths = getPaths SRC_ROOT, DEBUG_ROOT

gulp.task "jade", ->
    gulp
    .src paths.src.jade + "**"/[^_]*.jade",
        base: paths.src.jade
    .pipe plumber()
    .pipe jade
        pretty: true
    .pipe gulp.dest paths.dest.html

gulp.task "stylus", ->
    gulp
    .src paths.src.stylus + "**"/[^_]*.styl",
        base: paths.src.stylus
    .pipe plumber()
    .pipe stylus
        use: nib()
        define: STYLUS_DEF
    .pipe gulp.dest paths.dest.css

gulp.task "coffeeify", ->
    gulp
    .src paths.src.coffee + "**"/[^_]*.coffee",
        base: paths.src.coffee
    .pipe plumber()
    .pipe coffeeify()
    .pipe rename
        extname: ".js"
    .pipe gulp.dest paths.dest.js

gulp.task "test", ->
    gulp
    .src "spec/*.coffee"
    .pipe mocha
        reporter: "nyan"

gulp.task "default", ["jade", "stylus", "coffeeify", "copy-img"]

gulp.task "watch", ["connect"], ->
    gulp.watch (path.join paths.src.jade, "**|/*.jade"), ["jade"]
    gulp.watch (path.join paths.src.stylus, "**|/*.styl"), ["stylus"]
    gulp.watch (path.join paths.src.coffee, "**|/*.coffee"), ["coffeeify"]

gulp.task "connect", ->
    connect.server CONNECT_SETTING

###