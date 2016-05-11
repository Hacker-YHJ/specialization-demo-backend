###*
# Module dependencies.
###

app = require './app'
http = require 'http'
debug = require('debug')('site-backend:server')

###*
# Normalize a port into a number, string, or false.
###

normalizePort = (val) ->
  port = parseInt(val, 10)
  return val if isNaN port
  return port if port >= 0
  return false

###*
# Get port from environment and store in Express.
###

port = normalizePort(process.env.PORT or '3000')

###*
# Event listener for HTTP server "error" event.
###

onError = (error) ->
  throw error if error.syscall != 'listen'
  bind = if typeof port is 'string' then 'Pipe ' + port else 'Port ' + port
  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      console.error bind + ' requires elevated privileges'
      process.exit 1
    when 'EADDRINUSE'
      console.error bind + ' is already in use'
      process.exit 1
    else
      throw error

###*
# Event listener for HTTP server "listening" event.
###

onListening = ->
  addr = server.address()
  bind = if typeof addr is 'string' then 'pipe ' + addr else 'port ' + addr.port
  debug 'Listening on ' + bind

app.set 'port', port

###*
# Create HTTP server.
###

server = http.createServer app

###*
# Listen on provided port, on all network interfaces.
###

server.listen port
server.on 'error', onError
server.on 'listening', onListening
