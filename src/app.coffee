express = require 'express'
path = require 'path'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'

app = express()

# view engine setup
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()

# apply routes
app.use '/spec', require './routes/aol_scraper'

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next err

app.use (err, req, res, next) ->
  res.status err.status or 500
  res.send
    message: err.message
    error: {}

exports = module.exports = app
