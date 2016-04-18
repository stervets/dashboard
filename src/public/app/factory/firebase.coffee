module.exports =
  inject: '$firebaseObject, $firebaseArray'

  firebase: new Firebase FIREBASE_ADDR

  db:{}
  loaded: {}

  onLoadedFirebaseEntity: (name)->
    (entity)=>
      #console.log entity
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

  getWidgetsArray: (uid)->
    @loadFirebaseArray "widgets", "widgets/#{uid}"

