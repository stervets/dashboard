# utils
#path = require "path"
#args = (require "yargs").argv


# gulp
gulp = require "gulp"
plumber = require "gulp-plumber"
jade = require "gulp-jade"
stylus = require "gulp-stylus"
coffeeify = require "gulp-coffeeify"
cson = require "gulp-cson"
config = require "gulp-site-config"
globalShim = require "browserify-global-shim"
nib = require "nib"

argv = (require "yargs").argv
connect = require 'gulp-connect'
siteConfig = {}

params =
    path:
        public: "public"
        jadeCompile: "src/public/**/[^_]*.jade"
        jadeWatch: "src/public/**/*.jade"
        stylusCompile: "src/public/**/[^_]*.styl"
        stylusWatch: "src/public/**/*.styl"
        coffeeCompile:
            config: "src/public/config.coffee"
            app: "src/public/app.coffee"
        coffeeWatch: [
            "src/public/**/*.coffee"
            "^src/public/app.coffee"
        ]

    server: argv.server || 8080
    liveReload: argv.liveReload || 8081
    debug: argv.debug


logErrorMessage = (error)-> console.log error.message

gulp.task "getSiteConfig", ->
    gulp
    .src params.path.coffeeCompile.config
    .pipe plumber()
    .pipe cson()
    .pipe config siteConfig
    .on 'end', ->
        console.log siteConfig.config
        globalShim.configure siteConfig.config

###
    Build jade task
###
gulp.task "buildJade", ->
    gulp
    .src params.path.jadeCompile
    .pipe plumber()
    .pipe (
        jade
            pretty: params.debug
            locals: siteConfig.config
    )
    .pipe gulp.dest params.path.public
    .pipe connect.reload()

###
    Build styles task
###
gulp.task "buildStylus", ->
    gulp.src params.path.stylusCompile
    .pipe plumber()
    .pipe(
        stylus
            use: nib()
            compress: !params.debug
            'include css': true
    )
    .pipe gulp.dest params.path.public
    .pipe connect.reload()

###
    Build coffee task
###
gulp.task "buildCoffee", ->
    #coffeeify.transform globalShim
    globalShim.configure
        'aaaaa':
            'exports':
                a: 111111
                b: 222222
    gulp.src params.path.coffeeCompile.app
    .pipe plumber()
    .pipe(
        coffeeify
            options:
                debug: params.debug
                insertGlobals:
                    a: 222
                    b: 333
                insertGlobalVars:
                    aaaa: ->
                    bbbb: ->
                        a: 111
                        b: 222
    )
    .pipe gulp.dest params.path.public
    .pipe connect.reload()

###
    Build task
###

gulp.task "getSiteConfigAndCompile", ["getSiteConfig"], ->
    gulp.start "buildCoffee"
    gulp.start "buildJade"


gulp.task "build", ["getSiteConfigAndCompile"], ->
    gulp.start ["buildStylus"]

###
    Development task
###
gulp.task "devel", ["build"], ->
        gulp.watch params.path.jadeWatch, ["buildJade"]
        gulp.watch params.path.stylusWatch, ["buildStylus"]
        gulp.watch params.path.coffeeCompile.config, ["getSiteConfigAndCompile"]
        gulp.watch params.path.coffeeWatch, ["buildCoffee"]

        connect.server
            root: params.path.public
            port: params.server
            livereload:
                port: params.liveReload

gulp.task "default", ["build"]