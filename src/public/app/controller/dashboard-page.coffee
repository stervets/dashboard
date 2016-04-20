module.exports =
  inject: [FACTORY.USER, FACTORY.FIREBASE, FACTORY.DASHBOARD]
  local:
    scope:
      user: FACTORY.USER
      dashboard: FACTORY.DASHBOARD
      arrangeWidgets: FACTORY.DASHBOARD
      channels: FACTORY.DASHBOARD
      channelNames: FACTORY.DASHBOARD


      db: FACTORY.FIREBASE
      loaded: FACTORY.FIREBASE

      chartNames: []
      addChartWidget: LOCAL_METHOD
      addValueWidget: LOCAL_METHOD
      addChatWidget: LOCAL_METHOD
      addAboutWidget: LOCAL_METHOD
      expandWidgets: LOCAL_METHOD
      collapseWidgets: LOCAL_METHOD

    addChartWidget: (name, channel)->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: Math.floor @dashboard.tableWidth/2
        h: 3
        type: WIDGET.TYPE.CHART
        resize: true
        options: true
        data:
          name: name
          currency: channel
          type: 'area'
          
    addValueWidget: ->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: 2
        h: 2
        type: WIDGET.TYPE.VALUE
        resize: false
        options: true
        data:
          name: @channelNames[0]
          currency: @channels[0]

    addChatWidget: ->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: 3
        h: 6
        type: WIDGET.TYPE.CHAT
        resize: true
        options: false

    addAboutWidget: ->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: @dashboard.tableWidth
        h: 2
        type: WIDGET.TYPE.ABOUT
        resize: true
        options: false

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
    @$scope.chartNames = @channelNames.map (name)->name.replace('/', ' to ')
    @[FACTORY.FIREBASE].getWidgetsArray @user.id