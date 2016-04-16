module.exports =
  inject: [FACTORY.USER, FACTORY.FIREBASE]
  local:
    scope:
      firebase: FACTORY.FIREBASE
      db: FACTORY.FIREBASE
      user: FACTORY.USER
      dashboard: LOCAL_PROPERTY

    dashboard:
      loaded: false

    onDbWidgetsChange: ->
      @dashboard.loaded = @db.widgets?
      console.log @dashboard.loaded
      console.log @db.widgets

    watch:
      'db.widgets': 'onDbWidgetsChange'

  init: ->
    return unless @user.authenticated
    @[FACTORY.FIREBASE].getWidgetsArray @user.id
