var express  = require('express')
    , gridfs   = require('./gridfs')
    , mongoose = require('mongoose')

mongoose.connect('mongodb://localhost/test')

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

// model

var DudeSchema = new mongoose.Schema({
    name: String
  , files: [mongoose.Schema.Mixed]
});
DudeSchema.methods.addFile = function(file, options, fn){
    var dude = this;
    console.log(file)
    gridfs.putFile(file.path, file.filename, options, function(err, result){
      dude.files.push(result);
      dude.save(fn);
    });

}
var Dude = mongoose.model('Dude',DudeSchema);

// Routes

app.get('/', function(req, res){
  Dude.find({}, function(err, dudes){
    res.render('index', { title: 'Express', dudes:dudes })
  });
});

app.post('/new', function(req, res){
  var dude = new Dude();

  dude.name = req.body.name
  dude.addFile(req.files.file, {content_type:req.files.file.type}, function(err, result){
    res.redirect('/');
  });
});

app.get('/file/:id', function(req, res){
  gridfs.pipe(req.params.id, process.stdout);
});


app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
