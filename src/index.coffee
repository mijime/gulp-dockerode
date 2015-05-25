through2  = require 'through2'
util      = require 'gulp-util'
dockerode = require 'dockerode'
es        = require 'event-stream'

docker = new dockerode

runOptions =
  Tty: false
  OpenStdin: true
  StdinOnce: true

attachOptions =
  stdin: true
  stream: true

chunkStream = (file, callback) ->
  buffers = []

  transform = (buffer, encode, callback) ->
    # util.log 'chunkStream::transform', file
    buffers.push buffer
    callback null

  flush = (callback) ->
    # util.log 'chunkStream::flush', file
    copyFile = file.clone()
    copyFile.contents = Buffer.concat buffers
    this.push copyFile
    callback null

  stream = through2.obj transform, flush

  handlePipe = (file, _) ->
    # util.log 'chunkStream::handlePipe', file
    callback null, file
    _ null, file

  stream.pipe es.map handlePipe
  stream

errStream = es.map (buffer, callback) ->
  util.log buffer.toString 'utf8'
  callback null, buffer

gulpDockerode = (options) ->
  es.map (file, callback) ->
    # util.log 'gulpDockerode::handlePipe', file

    handleContainer = (c) ->
      # util.log 'handleContainer', res
      container = docker.getContainer c.id
      container.attach attachOptions, handleAttach

    handleAttach = (err, stream) ->
      # util.log 'handleAttach'
      return callback err, null if err

      stream.write file.contents
      file.pipe stream

    handleWait = (err, res, c) ->
      # util.log 'handleWait'
      return callback err, null if err

      container = docker.getContainer c.id
      container.remove handleRemove

    handleRemove = (err, res) ->
      # util.log 'handleRemove', err, res
      return callback err, null if err

    outStream = chunkStream file, callback

    docker.run options.Image, options.Cmd,
        [outStream, errStream], runOptions, handleWait
      .on 'container', handleContainer

module.exports = gulpDockerode
