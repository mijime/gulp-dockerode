var attachOptions, chunkStream, docker, dockerode, errStream, es, gulpDockerode, runOptions, through2, util;

through2 = require('through2');

util = require('gulp-util');

dockerode = require('dockerode');

es = require('event-stream');

docker = new dockerode;

runOptions = {
  Tty: false,
  OpenStdin: true,
  StdinOnce: true
};

attachOptions = {
  stdin: true,
  stream: true
};

chunkStream = function(file, callback) {
  var buffers, flush, handlePipe, stream, transform;
  buffers = [];
  transform = function(buffer, encode, callback) {
    buffers.push(buffer);
    return callback(null);
  };
  flush = function(callback) {
    var copyFile;
    copyFile = file.clone();
    copyFile.contents = Buffer.concat(buffers);
    this.push(copyFile);
    return callback(null);
  };
  stream = through2.obj(transform, flush);
  handlePipe = function(file, _) {
    callback(null, file);
    return _(null, file);
  };
  stream.pipe(es.map(handlePipe));
  return stream;
};

errStream = es.map(function(buffer, callback) {
  util.log(buffer.toString('utf8'));
  return callback(null, buffer);
});

gulpDockerode = function(options) {
  return es.map(function(file, callback) {
    var handleAttach, handleContainer, handleRemove, handleWait, outStream;
    handleContainer = function(c) {
      var container;
      container = docker.getContainer(c.id);
      return container.attach(attachOptions, handleAttach);
    };
    handleAttach = function(err, stream) {
      if (err) {
        return callback(err, null);
      }
      stream.write(file.contents);
      return file.pipe(stream);
    };
    handleWait = function(err, res, c) {
      var container;
      if (err) {
        return callback(err, null);
      }
      container = docker.getContainer(c.id);
      return container.remove(handleRemove);
    };
    handleRemove = function(err, res) {
      if (err) {
        return callback(err, null);
      }
    };
    outStream = chunkStream(file, callback);
    return docker.run(options.Image, options.Cmd, [outStream, errStream], runOptions, handleWait).on('container', handleContainer);
  });
};

module.exports = gulpDockerode;
