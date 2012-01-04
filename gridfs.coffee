mongoose = require("mongoose")
debug    = require("debug")("gridfs")
assert   = require("better-assert")

GridStore = mongoose.mongo.GridStore
Grid = mongoose.mongo.Grid

exports.get = (id, fn) ->
  ##debug "fetching %s", id
  db = mongoose.connection.db
  id = new mongoose.mongo.BSONPure.ObjectID(id)
  store = new GridStore(db, id, "r",{root: "fs"})
  store.open (err, store) ->
    assert not err
    return fn(err)  if err
    store.readBuffer fn

exports.put = (buf, name, fn) ->
  db = mongoose.connection.db
  ##debug "saving %d bytes as %s", buf.length, name
  new GridStore(db, name, "w").open (err, file) ->
    assert not err
    return fn(err)  if err
    file.write buf, true, fn

exports.putFile = (path, name, fn) ->
  db = mongoose.connection.db
  ##debug "saving %s as %s", path, name
  new GridStore(db, name, "w").open (err, file) ->
    assert not err
    return fn(err)  if err
    file.writeFile path, fn

exports.deleteFile = (id, fn) ->
  console.log "deleting " + id
  db = mongoose.connection.db
  id = new mongoose.mongo.BSONPure.ObjectID(id)
  store = new GridStore(db, id, "r",{root: "fs"})
  store.unlink (err, result) ->
    if err
      console.log err
      return fn(err)  if err
    return true

