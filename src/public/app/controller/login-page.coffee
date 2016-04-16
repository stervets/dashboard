module.exports =
    inject: [FACTORY.USER, '$timeout']
    local:
        scope:
            userStatus: FACTORY.USER
            authPopup: FACTORY.USER
            canShowLoginForm: false


        showLoginForm: ->
                @$scope.canShowLoginForm = true

    init: ->
        @$timeout @showLoginForm, 300