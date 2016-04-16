gulp = require "gulp"
plumber = require "gulp-plumber"
jade = require "gulp-jade"
stylus = require "gulp-stylus"
cson = require "gulp-cson"
siteConfig = require "gulp-site-config"
uglify = require "gulp-uglify"
vendor = require "gulp-concat-vendor"
browserifyReplace = require "browserify-replace"
nib = require "nib"

argv = (require "yargs").argv
connect = require 'gulp-connect'

publicGlobals = {}
vendorBundle = {}

###
  Gulp config
###
params =
  path:
    public: "public"
    jadeCompile: "src/public/**/[^_]*.jade"
    jadeWatch: "src/public/**/*.jade"
    stylusCompile: "src/public/app.styl"
    stylusWatch: "src/public/**/*.styl"
    coffeeCompile: "src/public/app.coffee"
    coffeeWatch: "src/public/**/*.coffee"

    publicGlobals: "src/config/public-globals.coffee"
    vendorBundle: "src/config/vendor-bundle.coffee"

  angularBundle: ['factory', 'controller', 'directive']
  replacePattern: ///"ANGULAR_BUNDLE_CODE"///g


  server: argv.server || 8080
  liveReload: argv.liveReload || 8081
  debug: argv.debug

###
  Transform "CamelCaseString" to "camel-case-string"
###
camelCaseToDash = (s)->
  s[0].toLowerCase() + s.slice(1).replace(
    ///([A-Z])///g, ($0)-> "-#{$0.toLowerCase()}"
  )

###
  Globals exports to jade and client scripts
###
gulp.task "getPublicGlobals", ->
  publicGlobals = {}
  gulp
  .src params.path.publicGlobals
  .pipe plumber()
  .pipe cson()
  .pipe siteConfig publicGlobals
  .on 'end', ->
    publicGlobals = publicGlobals[Object.keys(publicGlobals)[0]]

###
  Vendor libs
###
gulp.task "getVendorBundle", ->
  vendorBundle = {}
  gulp
  .src params.path.vendorBundle
  .pipe plumber()
  .pipe cson()
  .pipe siteConfig vendorBundle
  .on 'end', ->
    vendorBundle = vendorBundle[Object.keys(vendorBundle)[0]].map (name)->
      "vendor/#{name}"


###
  Concat vendors libs into vendor.js
###
gulp.task "buildVendorBundle", ["getVendorBundle"], ->
  unless vendorBundle?.length
    console.warn "Wrong vendor bundle config"
    return true
  vendorPipe = gulp.src vendorBundle
  .pipe plumber()
  .pipe vendor "vendor.js"
  vendorPipe = vendorPipe.pipe uglify() unless params.debug
  vendorPipe.pipe gulp.dest params.path.public
  .pipe connect.reload()
  true

###
    Build jade
###
gulp.task "buildJade", ->
  gulp
  .src params.path.jadeCompile
  .pipe plumber()
  .pipe (
    jade
      pretty: params.debug
      locals: publicGlobals
  )
  .pipe gulp.dest params.path.public
  .pipe connect.reload()
  true

###
    Build styles
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
  true

###
    Build coffee
###
gulp.task "buildCoffee", ->
  globalVars = {}
  for key, val of publicGlobals
    globalVars[key] = ((val)-> -> val)(JSON.stringify(val))

  angularBundleCode = ""
  params.angularBundle.forEach (bundleItem)->
    upcasedBundleItem = bundleItem.toUpperCase()
    return unless typeof publicGlobals[upcasedBundleItem] is 'object'
    for key, val of publicGlobals[upcasedBundleItem]
      filename = camelCaseToDash(val).split('-')
      filename.pop()
      angularBundleCode += "app.#{bundleItem} #{upcasedBundleItem}.#{key}, require(\"./app/#{bundleItem}/#{filename.join('-')}\")\n"

  Object.keys(require.cache).forEach (cacheItem)->
    if cacheItem.indexOf("gulp-coffeeify") >= 0
      delete require.cache[cacheItem]

  coffeePipe = gulp
  .src params.path.coffeeCompile
  .pipe plumber()
  .pipe(
    require("gulp-coffeeify")
      options:
        debug: params.debug
        insertGlobals: params.debug
        insertGlobalVars: globalVars
        transform: [
          [browserifyReplace,
            replace: [
              from: params.replacePattern
              to: angularBundleCode
            ]
          ]
        ]
  )
  coffeePipe = coffeePipe.pipe uglify() unless params.debug
  coffeePipe.pipe gulp.dest params.path.public
  .pipe connect.reload()
  true

###
  Rebuild coffee and jade with public global vars
###
gulp.task "getPublicGlobalsAndRebuild", ["getPublicGlobals"], ->
  gulp.start "buildCoffee"
  gulp.start "buildJade"
  true


###
  Build task
###
gulp.task "build", ["buildVendorBundle", "getPublicGlobalsAndRebuild"], ->
  gulp.start ["buildStylus"]

###
    Development task
###
gulp.task "devel", ["build"], ->
  gulp.watch params.path.jadeWatch, ["buildJade"]
  gulp.watch params.path.stylusWatch, ["buildStylus"]
  gulp.watch params.path.coffeeWatch, ["getPublicGlobalsAndRebuild"]
  gulp.watch params.path.publicGlobals, ["getPublicGlobalsAndRebuild"]
  gulp.watch params.path.vendorBundle, ["buildVendorBundle"]

  connect.server
    root: params.path.public
    port: params.server
    livereload:
      port: params.liveReload

gulp.task "default", ["build"]