module.exports =
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    templateUrl: "template-#{DIRECTIVE.WIDGET_CHAT}"
    inject: [FACTORY.FIREBASE, FACTORY.USER]
    local:
        scope:
            db: FACTORY.FIREBASE
            loaded: FACTORY.FIREBASE
            user: FACTORY.USER
            sendMessage: LOCAL_METHOD
            messageTo: LOCAL_METHOD
            isSelected: LOCAL_METHOD
            params: LOCAL_PROPERTY

        params:
            text: ''
            messages: null

        isSelected: (text)->text.indexOf(@user.name)>=0

        messageTo: (author)->
            @params.text=author+', '
            setTimeout (=>@$input.focus()), 100

        sendMessage: ->
            text = @params.text.trim()
            @params.text = ''
            return unless text
            @db.messages.$add
                time: Date.now()
                author: @user.name
                avatar: @user.avatar
                text: text
            if @db.messages.length>100
                @db.messages.$remove @db.messages[0]

        watch:
            'loaded.messages': ->
                @params.messages = @db.messages if @loaded.messages
    link: ->
        @$input = @$element.find '.jsMessageInput'