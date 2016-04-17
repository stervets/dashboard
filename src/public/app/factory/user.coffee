module.exports =
  inject: [FACTORY.FIREBASE, '$rootScope']

  user: {}

  userDefaults:
    authenticated: false
    id: null
    name: ''
    avatar: ''

  firebase: null

  onAuthWithOAuthPopup: (error, authData)->
    return if error?
    @authUser authData
    @$rootScope.$apply()

  authPopup: (provider)->
    @firebase.authWithOAuthPopup provider, @onAuthWithOAuthPopup

  logout: ->
    @resetUser()
    @[FACTORY.FIREBASE].unauth()
      
  resetUser: ->
    angular.extend @user, @userDefaults

  authUser: (authData)->
    return unless authData?.provider
    angular.extend @user,
      id: authData.uid
      authenticated: true
      name: authData[authData.provider].displayName
      avatar: authData[authData.provider].profileImageURL

  init: ->
    @resetUser()
    @firebase = @[FACTORY.FIREBASE].firebase
    @authUser authData if (authData = @firebase.getAuth())

