module.exports =
  inject: '$firebaseObject, $firebaseArray'

  firebase: new Firebase FIREBASE_ADDR

  db:{}
  loaded:
    newUser: false

  onLoadedFirebaseEntity: (name)->
    (entity)=>
      @db[name] = entity
      @loaded[name] = true

  loadFirebaseObject: (name, dbPath)->
    @db[name] = @$firebaseObject(@firebase.child(dbPath)).$loaded().then @onLoadedFirebaseEntity(name)

  loadFirebaseArray: (name, dbPath)->
    @db[name] = @$firebaseArray(@firebase.child(dbPath)).$loaded().then @onLoadedFirebaseEntity(name)

  unauth: ->
    @firebase.unauth()
    for name, entity of @db when entity?
      entity.$destroy()
      @db[name] = null
      @loaded[name] = false

  isNewUser: (snapshot)->
    @loaded.newUser = !snapshot.val()?

  getWidgetsArray: (uid)->
    widgetsPath = "widgets/#{uid}"
    @firebase.child(widgetsPath).once 'value', @isNewUser
    @loadFirebaseArray "widgets", widgetsPath
    @loadFirebaseArray "messages", "messages"

