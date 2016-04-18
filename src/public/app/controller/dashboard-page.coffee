module.exports =
  inject: [FACTORY.USER, FACTORY.FIREBASE, FACTORY.DASHBOARD]
  local:
    scope:
      user: FACTORY.USER
      dashboard: FACTORY.DASHBOARD
      arrangeWidgets: FACTORY.DASHBOARD

      db: FACTORY.FIREBASE
      loaded: FACTORY.FIREBASE

      addWidget: LOCAL_METHOD
      expandWidgets: LOCAL_METHOD
      collapseWidgets: LOCAL_METHOD


    addWidget: (type)->
      @[FACTORY.DASHBOARD].addWidget
        type: type
        x: 0
        y: 0
        w: Math.floor @dashboard.tableWidth/2
        h: 3

    expandWidgets: ->
      @db.widgets.forEach (widget)=>
        widget.w = @dashboard.tableWidth
        widget.h = 3
      @arrangeWidgets()

    collapseWidgets: ->
      @db.widgets.forEach (widget)=>
        widget.w = Math.floor @dashboard.tableWidth/2
        widget.h = 3
      @arrangeWidgets()

  init: ->
    return unless @user.authenticated
    @[FACTORY.FIREBASE].getWidgetsArray @user.id