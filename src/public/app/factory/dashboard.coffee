webworkify = require '../../../../vendor/webworkify'
dashboardWorker = require '../dashboard-worker'

module.exports =
    inject: [FACTORY.FIREBASE, '$q']
    dashboard:
        tableWidth: DASHBOARD.TABLE_WIDTH
        tableHeight: 0
        cellSpace: DASHBOARD.CELL.SPACE
        cellWidth: 0
        cellHeight: DASHBOARD.CELL.HEIGHT + DASHBOARD.CELL.SPACE
        cellInnerWidth: 0
        cellInnerHeight: DASHBOARD.CELL.HEIGHT

    worker: null
    defers: {}
    workerHandlers: {}

    prepareWidgetData: (widget)->
        return null unless widget?
        id: widget.id
        x: widget.x
        y: widget.y
        w: widget.w
        h: widget.h

    prepareWidgetsData: (widgets, withoutThisWidget)->
        preparedWidgets = []
        #widgets.forEach (widget)=>
        for widget in widgets when !withoutThisWidget or widget.id isnt withoutThisWidget.id
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>> test this
            preparedWidgets.push @prepareWidgetData(widget)
        preparedWidgets

    postMessage: (message)->
        deferId = Triangle.genId()
        @defers[deferId] = @$q.defer()
        @worker.postMessage angular.extend(message, deferId: deferId)
        @defers[deferId].promise

    getCollision: (widget, widgets, doNotPrepareWidgets)->
        @postMessage
            com: 'getCollision'
            widget: @prepareWidgetData widget
# >>>>>>>>>>>>>>>>>>>>> WHY doNotPrepareWidgets?
            widgets: if doNotPrepareWidgets? then widgets else @prepareWidgetsData widgets, widget
            tableWidth: @dashboard.tableWidth

    getFreePlace: (widget, widgets)->
        @postMessage
            com: 'getFreePlace'
            widget: @prepareWidgetData widget
            widgets: @prepareWidgetsData widgets, widget
            tableWidth: @dashboard.tableWidth
            scrollTo: widget.id

# >>>>>>>>>>>>>>>>> why you need this?
    sortWidgets: (widgets)-> widgets.sort (a, b)->
        aa = a.y * @dashboard.tableWidth + a.x
        bb = b.y * @dashboard.tableWidth + b.x
        return 0 if aa is bb
        return if aa < bb then -1 else 1


    arrangeWidgets: (widgets, onlyAfterThisWidget)->
        widget = @prepareWidget onlyAfterThisWidget
        @postMessage
            com: 'arrangeWidgets'
            widgets: @prepareWidgetsData widgets
            widget: widget # why without prepare ??
            tableWidth: @dashboard.tableWidth
            scrollTo: widget

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

    getWidget: (id)->@db.widgets.$getRecord id: id

    addWidget: (params)->
        widget = angular.extend params,
            id: Triangle.genId()
        @db.widgets.$add widget
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

    init: ->
        @db = @[FACTORY.FIREBASE].db
        @worker = webworkify dashboardWorker
