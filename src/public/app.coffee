appRoutes = require('./app/routes')

app = new Triangle APPLICATION, [
  'ngRoute'
  'ngAnimate'
], appRoutes.routes

app.angular.config appRoutes.disableHtml5Mode

app.controller CONTROLLER.MAIN,
  init: ->
    console.log CONTROLLER.MAIN


"ANGULAR_BUNDLE_CODE"