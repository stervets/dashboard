MODULE_NAME = 'ApplicationModule'
module = new Triangle MODULE_NAME

# Driven by gulp. Do not remove the line below.
"ANGULAR_BUNDLE_CODE"

router = require('./app/router')

app = new Triangle APPLICATION.NAME, APPLICATION.MODULES.concat([MODULE_NAME]), router.routes


app.angular.config router.disableHtml5Mode
app.angular.config ['$mdThemingProvider', ($mdThemingProvider)->
  theme = $mdThemingProvider.theme('default')
  theme = theme.dark() if THEME.DARK
  theme
  .primaryPalette THEME.PRIMARY_PALETTE
  .accentPalette THEME.ACCENT_PALETTE
]
