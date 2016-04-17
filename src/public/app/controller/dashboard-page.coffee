module.exports =
  inject: [FACTORY.USER, FACTORY.FIREBASE, FACTORY.DASHBOARD]
  local:
    scope:
      user: FACTORY.USER
      dashboard: FACTORY.DASHBOARD
      db: FACTORY.FIREBASE
      addWidget: LOCAL_METHOD

    addWidget: (type)->
      @[FACTORY.DASHBOARD].addWidget
        type: type
        x: 0
        y: 0
        w: Math.floor @dashboard.tableWidth/2
        h: 2

  init: ->
    return unless @user.authenticated
    @[FACTORY.FIREBASE].getWidgetsArray @user.id