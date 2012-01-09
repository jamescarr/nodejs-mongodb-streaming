mongoose = require "mongoose"
request  = require "request"

GridStore = mongoose.mongo.GridStore
Grid      = mongoose.mongo.Grid
ObjectID = mongoose.mongo.BSONPure.ObjectID


exports.get = (id, fn) ->
  db = mongoose.connection.db
  id = new ObjectID(id)
  store = new GridStore(db, id, "r",
    root: "fs"
  )
  store.open (err, store) ->
    return fn(err)  if err
    # band-aid
    if "#{store.filename}" == "#{store.fileId}" and store.metadata and store.metadata.filename
      store.filename = store.metadata.filename
    fn null, store

exports.put = (buf, name, options..., fn) ->
  db = mongoose.connection.db
  options = parse(options)
  options.metadata.filename = name
  new GridStore(db, name, "w", options).open (err, file) ->
    return fn(err)  if err
    file.write buf, true, fn

exports.putFile = (path, name, options, fn) ->
  db = mongoose.connection.db
  options = parse(options)
  options.metadata.filename = name
  new GridStore(db, name, "w", options).open (err, file) ->
    return fn(err)  if err
    file.writeFile path, fn

exports.deleteFile = (id, fn) ->
  db = mongoose.connection.db
  id = new ObjectID(id)
  db.open (err, db) ->
    db.collection 'fs.files', (err, files) ->
      files.findOne _id:id, (err, file) ->
        console.log "deleting the file '#{file.filename}'"
        db.collection 'fs.files', (err, files) ->
          files.count (err, count) ->
            console.log "The count is #{count}"
        GridStore.unlink db, file.filename, {root:'fs'}, (err, gs) ->
          db.collection 'fs.files', (err, files) ->
            files.count (err, count) ->
              console.log "The count is #{count}"
          console.log "DELETED!"
          fn(null, file)

parse = (options) ->
  opts = {}
  if options.length > 0
    opts = options[0]
  if !opts.metadata
    opts.metadata = {}
  opts
