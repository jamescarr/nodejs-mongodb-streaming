var mongoose = require("mongoose")
    , request = require('request')

var GridStore = mongoose.mongo.GridStore;
var Grid = mongoose.mongo.Grid;

  exports.get = function(id, fn) {
    var db, store;
    db = mongoose.connection.db;
    id = new mongoose.mongo.BSONPure.ObjectID(id);
    store = new GridStore(db, id, "r", {
      root: "fs"
    });
    return store.open(function(err, store) {
      if (err) return fn(err);
      return store.readBuffer(fn);
    });
  };
  exports.pipe = function(id, outstream) {
    var db, store;
    db = mongoose.connection.db;
    id = new mongoose.mongo.BSONPure.ObjectID(id);
    store = new GridStore(db, id, "r", {
      root: "fs"
    });
    store.stream(true).pipe(outstream)
  };

  exports.put = function(buf, name, fn) {
    var db;
    db = mongoose.connection.db;
    return new GridStore(db, name, "w").open(function(err, file) {
      if (err) return fn(err);
      return file.write(buf, true, fn);
    });
  };

  exports.putFile = function(path, name, options, fn) {
    var db = mongoose.connection.db;
    return new GridStore(db, name, "w", options).open(function(err, file) {
      if (err) return fn(err);
      return file.writeFile(path, fn);
    });
  };

  exports.deleteFile = function(id, fn) {
    var db, store;
    console.log("deleting " + id);
    db = mongoose.connection.db;
    id = new mongoose.mongo.BSONPure.ObjectID(id);
    store = new GridStore(db, id, "r", {
      root: "fs"
    });
    return store.unlink(function(err, result) {
      if (err) {
        console.log(err);
        if (err) return fn(err);
      }
      return true;
    });
  };
