module.exports =
  inject: '$firebaseObject, $firebaseArray'

  db:
    widgets: null

  firebase: new Firebase FIREBASE_ADDR

  getWidgetsArray: (uid)->
    @db.widgets = @$firebaseArray @firebase.child("widgets/#{uid}")
