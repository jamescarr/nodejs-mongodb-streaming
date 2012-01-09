# Node.js Mongoose+GridFS Example
Half baked thoughts with more to come.

This application illustrates using mongodb's GridStore through mongoose
to store files in  mongodb's [GridFS](http://www.mongodb.org/display/DOCS/GridFS). 

An interesting addition is that when files are downloaded they are
streamed from mongodb rather than loading the whole file into memory at
once.

## Try it out
### Requirements
* node.js (tested on v0.6.6)
* coffee-script
* mongodb (must be running)
* npmjs

### Running it
Install the dependencies by typing

```bash
  npm install .
```

And run it via coffee by typing

```bash
  coffee app
```
### Running the Tests
From the root of the project:
```bash
  mocha
```
Have fun!
