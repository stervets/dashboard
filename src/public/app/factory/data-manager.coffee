module.exports =
    socket: null

    subscribers: {}
    sendCache: []

    dataCache: {}

    handlers:
        data: (data)->
            return unless data?.channel and @subscribers[data.channel]?
            @dataCache[data.channel] = [] unless @dataCache[data.channel]?
            cache = @dataCache[data.channel]
            cache.push.apply cache, data.data
            cache.splice 0, cache.length-DATA_CACHE
            for handler in @subscribers[data.channel]
                handler data.data

    subscribe: (channel, handler)->
        unless @subscribers[channel]? 
            @subscribers[channel] = []

        unless @subscribers[channel].length
            @send SOCKET.SUBSCRIBE, channel

        handler @dataCache[channel] if @dataCache[channel]?
        @subscribers[channel].push handler
            
        
    unsubscribe: (channel, handler)->
        return unless @subscribers[channel]?
        @subscribers[channel].splice @subscribers[channel].indexOf(handler), 1
        unless @subscribers[channel].length
            @dataCache[channel].splice 0, @dataCache[channel].length if @dataCache[channel]?
            @send SOCKET.UNSUBSCRIBE, channel
    
    onSocketOpen: ->
        console.log "Socket opened"
        while @sendCache.length
            cache = @sendCache.pop()
            @send cache... unless cache[0] is SOCKET.SUBSCRIBE

        Object.keys(@subscribers).forEach (channel)=>
            @send SOCKET.SUBSCRIBE, channel

    onSocketClose: ->
        console.warn 'Socket closed'
        setTimeout @socketInit, 1000

    onSocketMessage: (message)->
        try
            message = JSON.parse message.data
        catch e
            message = null

        if message?.com and @handlers[message.com]?
            @handlers[message.com].call @, message.data

    send: (com, data)->
        if @socket.readyState
            @socket.send JSON.stringify
                com: com
                data: data
        else
            @sendCache.push [com, data]

    socketInit: ->
        @socket = new SockJS SOCKET_ADDR
        angular.extend @socket,
            onopen: @onSocketOpen
            onclose: @onSocketClose
            onmessage: @onSocketMessage
            
    init: ->
        @socketInit()