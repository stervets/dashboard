webworkify = require '../../../../vendor/webworkify'
dashboardWorker = require '../dashboard-worker'

module.exports =
  inject: [FACTORY.FIREBASE, '$q', '$rootScope']
  dashboard:
    tableWidth: DASHBOARD.TABLE_WIDTH
    tableHeight: 0
    cellSpace: DASHBOARD.CELL.SPACE
    cellWidth: 0
    cellHeight: DASHBOARD.CELL.HEIGHT + DASHBOARD.CELL.SPACE
    cellInnerWidth: 0
    cellInnerHeight: DASHBOARD.CELL.HEIGHT
    widgetMinWidth: 0
    widgetMinHeight: WIDGET.MIN_HEIGHT * (DASHBOARD.CELL.HEIGHT + DASHBOARD.CELL.SPACE) - DASHBOARD.CELL.SPACE
    scrollTo: null
    clientArea:
      top: 0
      left: 0
      width: 0
      height: 0
      
  worker: null
  defers: {}
  workerHandlers: {}

  setCellsize: (tableWidthInPixels)->
    @dashboard.cellWidth = tableWidthInPixels / @dashboard.tableWidth
    angular.extend @dashboard,
      cellInnerWidth: @dashboard.cellWidth - @dashboard.cellSpace
      widgetMinWidth: (@dashboard.cellWidth * WIDGET.MIN_WIDTH) - @dashboard.cellSpace
      tableRealWidth:  (@dashboard.cellWidth * @dashboard.tableWidth) - @dashboard.cellSpace

  prepareWidgetData: (widget)->
    return null unless widget?
    $id: widget.$id
    x: widget.x
    y: widget.y
    w: widget.w
    h: widget.h

  prepareWidgetsData: (withoutThisWidget)->
    preparedWidgets = []
    for widget in @db.widgets when !withoutThisWidget or widget.$id isnt withoutThisWidget.$id
      preparedWidgets.push @prepareWidgetData(widget)
    preparedWidgets

  postMessage: (message)->
    deferId = Triangle.genId()
    @defers[deferId] = @$q.defer()
    @worker.postMessage angular.extend(message, deferId: deferId)
    @defers[deferId].promise

  getCollision: (widget, preparedWidgets)->
    @postMessage
      com: 'getCollision'
      widget: @prepareWidgetData widget
      widgets: if preparedWidgets? then preparedWidgets else @prepareWidgetsData widget
      tableWidth: @dashboard.tableWidth

  getFreePlace: (widget)->
    @postMessage
      com: 'getFreePlace'
      widget: @prepareWidgetData widget
      widgets: @prepareWidgetsData widget
      tableWidth: @dashboard.tableWidth
      scrollTo: widget.$id

# >>>>>>>>>>>>>>>>> why you need this?
#    sortWidgets: -> @db.widgets.sort (a, b)->
#        aa = a.y * @dashboard.tableWidth + a.x
#        bb = b.y * @dashboard.tableWidth + b.x
#        return 0 if aa is bb
#        return if aa < bb then -1 else 1


  arrangeWidgets: (onlyAfterThisWidget)->
    widget = @prepareWidgetData onlyAfterThisWidget
    @postMessage(
      com: 'arrangeWidgets'
      widgets: @prepareWidgetsData()
      widget: widget # why without prepare ??
      tableWidth: @dashboard.tableWidth
      scrollTo: widget
    ).then @saveAll

  registerWorkerHandler: (command, handler)->
    @workerHandlers[command] = [] unless @workerHandlers[command]?
    @workerHandlers[command].push handler

  onWorkerMessage: (e)->
    data = e.data
    if @workerHandlers[data.com]?
      for handler in @workerHandlers[data.com]
        handler data

    if @defers[data.deferId]
      @defers[data.deferId][(if data.error? then 'reject' else 'resolve')] data

  getWidget: (widget)->
    return if typeof widget is 'object' then widget else @db.widgets.$getRecord widget

  addWidget: (widget)->
    @db.widgets.$add(widget).then (ref)=>
      widget.$id = ref.key()
      @getFreePlace widget, @db.widgets

  getTableXY: (x, y)->
    x: Math.round(x / @dashboard.cellWidth)
    y: Math.round(y / @dashboard.cellHeight)

  getRealXY: (x, y)->
    x: x * @dashboard.cellWidth
    y: y * @dashboard.cellHeight

  getRealWH: (w, h)->
    w: w * @dashboard.cellWidth - @dashboard.cellSpace
    h: h * @dashboard.cellHeight - @dashboard.cellSpace

  getTableWH: (w, h)->
    w: Math.round(w / @dashboard.cellWidth)
    h: Math.round(h / @dashboard.cellHeight)

  moveWidgets: (data)->
    @dashboard.scrollTo = data.scrollTo if data.scrollTo
    for widgetData in data.widgets
      angular.extend @getWidget(widgetData.$id), widgetData
    @$rootScope.$apply()
    
  saveAll: ->
    for widget in @db.widgets
      @db.widgets.$save widget

  save: (widget)->
    @db.widgets.$save @getWidget(widget)

  remove: (widget)->
    widget = @getWidget widget
    @db.widgets.$remove(widget).then =>
      @arrangeWidgets()

  init: ->
    @db = @[FACTORY.FIREBASE].db
    @worker = webworkify dashboardWorker
    @worker.onmessage = @onWorkerMessage
    @registerWorkerHandler 'moveWidgets', @moveWidgets