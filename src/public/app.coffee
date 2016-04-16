appRoutes = require('./app/routes')

app = new Triangle APPLICATION, [
  'ngRoute'
  'ngAnimate'
], appRoutes.routes

app.angular.config appRoutes.disableHtml5Mode

# Driven by gulp. Do not remove the line below.
"ANGULAR_BUNDLE_CODE"