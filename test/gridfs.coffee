should      = require("should")
gridfs      = require("../gridfs")
mongoose    = require("mongoose")
util        = require('util')
buffertools = require "buffertools"

GridStore = mongoose.mongo.GridStore

describe "GridFS", ->
  before (done) ->
    mongoose.connect "mongodb://localhost/gridfs-test", done
  describe "put/get", ->
    describe "without options", ->
      id = ''
      before (done) ->
        gridfs.put new Buffer("Hello World"), "hello_world.txt", (err, result) ->
          id = result.fileId+""
          done()

      it "should store store contents", (done) ->
        gridfs.get id, (err, store) ->
          store.readBuffer (err, contents) ->
            contents.toString().should.equal "Hello World"
            done()

      it "should contain correct filename when getting it", (done) ->
        gridfs.get id, (err, store) ->
            store.filename.should.equal "hello_world.txt"
            done()

      it "can stream the file to an output stream", (done) ->
        gridfs.get id, (err, store) ->
          out = new buffertools.WritableBufferStream()
          util.pump store.stream(true), out, ->
            "#{out.getBuffer()}".should.equal "Hello World"
            done()

    describe "with options", ->
      options = 
        content_type: 'text/plain'
      it "should store store contentType if specififed", (done) ->
          gridfs.put new Buffer("Hello World"), "hello_world.txt", options, (err, result) ->
            id = "#{result.fileId}"
            gridfs.get id, (err, store) ->
              store.contentType.should.equal "text/plain"
              done()
