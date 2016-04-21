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
      resetToDefault: LOCAL_METHOD

    addChartWidget: (name, channel)->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: Math.floor @dashboard.tableWidth / 2
        h: 3
        type: WIDGET.TYPE.CHART
        resize: true
        options: true
        data:
          name: name
          currency: channel
          type: 'area'

    addValueWidget: (index)->
      @[FACTORY.DASHBOARD].addWidget
        x: 0
        y: 0
        w: 1
        h: 1
        type: WIDGET.TYPE.VALUE
        resize: false
        options: false
        data:
          name: @channelNames[index]
          currency: @channels[index]

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
        return unless widget.resize
        widget.w = @dashboard.tableWidth
        widget.h = 3
      @arrangeWidgets()

    collapseWidgets: ->
      @db.widgets.forEach (widget)=>
        return unless widget.resize
        widget.w = Math.floor @dashboard.tableWidth / 2
        widget.h = 3
      @arrangeWidgets()

    export: ->
      return unless Array.isArray @db.widgets
      widgets = []
      @db.widgets.forEach (w)->
        widgets.push
          x: w.x
          y: w.y
          w: w.w
          h: w.h
          type: w.type
          resize: w.resize
          options: w.options
          data: w.data
      console.log JSON.stringify widgets

    resetToDefault: ->
      return unless Array.isArray @db.widgets
      @db.widgets.slice().forEach (widget)=>
        @db.widgets.$remove widget
      @addDefaultWidgets()

    addDefaultWidgets: ->
      return unless Array.isArray @db.widgets
      DEFAULT_DASHBOARD.forEach (widget)=>
        @[FACTORY.DASHBOARD].addWidget widget, 'withGetNoFreePlace'
        setTimeout @[FACTORY.DASHBOARD].saveAll, 1000

    onNewUserLogined: ->
      if @loaded.newUser
        @addDefaultWidgets()

    watch:
      'loaded.newUser': 'onNewUserLogined'
  init: ->
    return unless @user.authenticated
    @$scope.chartNames = @channelNames.map (name)-> name.replace('/', ' to ')
    @[FACTORY.FIREBASE].getWidgetsArray @user.id
