express = require 'express'
router = express.Router()
parseString = require('xml2js').parseString
request = require 'request'
cheerio = require 'cheerio'

makeQuery = (arr) ->
  str = escape(arr.join(' '))
  "http://search.aol.com/aol/news?q=#{str}&s_it=searchtabs&s_chn=prt_bon-news&v_t=comsearch-b"

s2d = (s) ->
  s = s.replace(/ /g,'+').replace(/!/g,'.')
  n = []
  for i in [0...s.length]
    n.push s.charCodeAt(i)
  n

anonymize = (s) ->
  arr = s2d s
  s2 = ''
  for i in [0...arr.length]
    s2 += arr[i].toString(36)
  s2

deanonymize = (s) ->
  arr = s.split /(..)/
  arr2 = []
  s2 = ''
  for i in [0...arr.length]
    arr2.push parseInt(arr[i],36) if arr[i]
  for i in [0...arr2.length]
    s2 += String.fromCharCode arr2[i]
  s2.replace(/\+/g,' ')

router.post '/user', (req, res, next) ->
  tags = anonymize(req.body.username)
  request.get "http://localhost:8888/tags?userid=#{tags}", (error, response, body) ->
    if error
      res.status(500).end()
    else if response.statusCode isnt 200
      res.status(501).end()
    if response.length is null
      # TODO
      # new user
      res.send ''
    else
      # TODO
      # to go hot
      res.send ''

router.get '/hot', (req, res, next) ->
  url = 'http://www.aol.com/news/'
  request.get url, (error, response, body) ->
    result = []
    if error
      res.status(500).end()
    else if response.statusCode isnt 200
      res.status(501).end()
    else
      $ = cheerio.load body
      $items = $('div.subitems > div.subitem')
      $items.each (i, elem) ->
        obj = {}
        obj.link = $(elem).find('a.link-out').attr('href')
        obj.title = $(elem).find('div.article-copy h3').text()
        obj.img = $(elem).find('img').attr('src')
        result[i] = obj
      res.send result

router.get '/rec', (req, res, next) ->

  # array of tags
  # TODO call a function to get tags
  # pass into makeQuery
  console.log req.query.tags

  #

  request.get makeQuery(req.query.tags), (error, response, body) ->
    result = []
    if error
      res.status(500).end()
    else if response.statusCode isnt 200
      res.status(501).end()
    else
      $ = cheerio.load body
      $items = $('div.NR ul li')
      regx = /background-image:url\(\'(.*)\'\)/
      $items.each (i, elem) ->
        obj = {}
        obj.link = $(elem).find('div.news_title a').attr('href')
        obj.title = $(elem).find('div.news_title a').text()
        obj.img = $(elem).find('div.news_thumbnail_img').attr('style')
        obj.img = obj.img?.match(regx)[1]
        result[i] = obj
      res.send result

exports = module.exports = router
