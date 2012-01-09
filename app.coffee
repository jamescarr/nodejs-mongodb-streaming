express = require("express")
gridfs = require("./gridfs")
mongoose = require("mongoose")

mongoose.connect "mongodb://localhost/test"
app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

DudeSchema = new mongoose.Schema(
  name: String
  files: [ mongoose.Schema.Mixed ]
)
DudeSchema.methods.addFile = (file, options, fn) ->
  dude = this
  gridfs.putFile file.path, file.filename, options, (err, result) ->
    dude.files.push result
    dude.save fn

Dude = mongoose.model("Dude", DudeSchema)
app.get "/", (req, res) ->
  Dude.find {}, (err, dudes) ->
    res.render "index",
      title: "GridFS Example"
      dudes: dudes

app.post "/new", (req, res) ->
  dude = new Dude()
  dude.name = req.body.name
  opts = 
    content_type: req.files.file.type
  dude.addFile req.files.file, opts, (err, result) ->
    res.redirect "/"

app.delete "/file/:id", (req, res) ->
  gridfs.deleteFile "#{req.params.id}", (err, file) ->
    console.log err
    console.log file
    res.redirect '/'

app.get "/file/:id", (req, res) ->
  gridfs.get req.params.id, (err, file) ->
    res.header "Content-Type", file.type
    res.header "Content-Disposition", "attachment; filename=#{file.filename}"
    file.stream(true).pipe(res)

app.listen 3000, ->
  console.log "Server running. Navigate to localhost:3000"
