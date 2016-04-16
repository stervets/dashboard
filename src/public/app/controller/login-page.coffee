module.exports =
  inject: [FACTORY.USER, '$timeout', '$location']
  local:
    scope:
      user: FACTORY.USER
      authPopup: FACTORY.USER
      canShowLoginForm: false

    showLoginForm: ->
      @$scope.canShowLoginForm = true

    onUserAuthenticatedChange: ->
      @$location.url '/dashboard' if @user.authenticated

    watch:
      'user.authenticated': 'onUserAuthenticatedChange'
  init: ->
    @[FACTORY.USER].logout()
    @$timeout @showLoginForm, 300