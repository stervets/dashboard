module.exports =
    inject: '$firebaseObject'
    userStatus:
        auth: false
        gotAuthStatus: false

    firebase: null
    auth: null

    onAuth: (error, authData)->
        console.log error, authData

    authPopup: (provider)->
        return unless provider in AUTH_PROVIDERS
        @firebase.authWithOAuthPopup provider, @onAuth

    init: ->
        @firebase = new Firebase FIREBASE_ADDR
        @auth = @firebase.getAuth()
        @userStatus.auth = !!@auth
        @userStatus.gotAuthStatus = true
