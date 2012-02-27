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

ApplicationSchema = new mongoose.Schema(
  name: String
  files: [ mongoose.Schema.Mixed ]
)
ApplicationSchema.methods.addFile = (file, options, fn) ->
  application = this
  gridfs.putFile file.path, file.filename, options, (err, result) ->
    application.files.push result
    application.save fn

Application = mongoose.model("application", ApplicationSchema)
app.get "/", (req, res) ->
  Application.find {}, (err, applications) ->
    res.render "index",
      title: "GridFS Example"
      applications: applications

app.post "/new", (req, res) ->
  application = new Application()
  application.name = req.body.name
  opts = 
    content_type: req.files.file.type
  application.addFile req.files.file, opts, (err, result) ->
    res.redirect "/"

app.get "/file/:id", (req, res) ->
  gridfs.get req.params.id, (err, file) ->
    res.header "Content-Type", file.type
    res.header "Content-Disposition", "attachment; filename=#{file.filename}"
    file.stream(true).pipe(res)

app.listen 3000, ->
  console.log "Server running. Navigate to localhost:3000"
