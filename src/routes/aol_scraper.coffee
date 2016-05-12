express = require 'express'
router = express.Router()
parseString = require('xml2js').parseString
request = require 'request'
cheerio = require 'cheerio'
lda = require 'lda'
fs = require 'fs'
path = require 'path'
nlp = require "nlp_compromise"


cleanText = (text) ->
  text = text.replace(/(?:^|\W)&(\w+)(?!\w)/ig,"")
  text = text.replace(/(?:^|\W)@(\w+)(?!\w)/ig,"")

  # text = text.replace(/\b&\S/ig,"")
  # text = text.replace(/\b#\S/ig,"")
  text = text.replace(/you/ig,"")
  text = text.replace(/person/ig,"")
  text = text.replace(/my/ig,"")
  text = text.replace(/he/ig,"")
  text = text.replace(/she/ig,"")
  text = text.replace(/man/ig,"")
  text = text.replace(/dude/ig,"")
  text = text.replace(/women/ig,"")
  text = text.replace(/someone/ig,"")
  text = text.replace(/boy/ig,"")
  text = text.replace(/girl/ig,"")
  text = text.replace(/i/ig,"")
  text = text.replace(/bro/ig,"")
  text = text.replace(/guy/ig,"")
  text = text.replace(/mom/ig,"")
  text = text.replace(/dad/ig,"")
  punctuationless = text.replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g,"")
  text = punctuationless.replace(/\s{2,}/g," ")
  text


getTopicsfromLDA = (text) ->

  text = cleanText text
  nlptext = nlp.text(text)
  #console.log(nlptext.root())
  #documents = text.match( /[^\.!\?]+[\.!\?]+/g )
  people = nlptext.people()
  organization = nlp.text(text).organizations()
  places = nlp.text(text).places()



  for i in [0...organization.length]
    console.log(organization[i].text)

  #console.log("people")
  #console.log(people)
  # console.log("organization")
  # console.log(organization)
  # console.log("places")
  # console.log(places)

  #console.log documents
  result = people#lda(documents, 5, 1)
  # console.log(result)
  result



extractPeople = (text, peopleArray) ->
  text = cleanText text
  nlptext = nlp.text(text)
  people = nlptext.people()
  for i in [0...people.length]
    if peopleArray.indexOf(people[i].text) < 0
      peopleArray.push(people[i].text)
  peopleArray

extractOrganizations = (text, orgArray) ->
  text = cleanText text
  nlptext = nlp.text(text)
  org = nlptext.organizations()
  for i in [0...org.length]
    if orgArray.indexOf(org[i].text) < 0
      orgArray.push(org[i].text)
  orgArray

extractPlaces = (text, placeArray) ->
  text = cleanText text
  nlptext = nlp.text(text)
  places = nlptext.places()
  for i in [0...places.length]
    if placeArray.indexOf(places[i].text) < 0
      placeArray.push(places[i].text)
  placeArray

pad = (str, max) ->
  str = str.toString()
  while str.length < max
    str = "0" + str
  str

router.get '/clienttrain', (req, res, next) ->

  bPeopleArray = []
  bPlaceArray = []
  bOrganizationArray = []

  pPeopleArray = []
  pPlaceArray = []
  pOrganizationArray = []

  sPeopleArray = []
  sPlaceArray = []
  sOrganizationArray = []

  ePeopleArray = []
  ePlaceArray = []
  eOrganizationArray = []

  tPeopleArray = []
  tPlaceArray = []
  tOrganizationArray = []

  # entertainment - 387
  # politics - 418
  # sport - 512
  # tech - 402
  # business - 511


  for i in [1...511]
    fileName = pad i, 3
    fileName += ".txt"
    filename = path.join(__dirname, '../../data/bbc/business/' + fileName)
    txt = fs.readFileSync filename, 'utf8'
    extractPeople txt.toString(), bPeopleArray
    extractPlaces txt.toString(), bPlaceArray
    extractOrganizations txt.toString(), bOrganizationArray


  for i in [1...512]
    fileName = pad i, 3
    fileName += ".txt"
    filename = path.join(__dirname, '../../data/bbc/sport/' + fileName)
    txt = fs.readFileSync filename, 'utf8'
    extractPeople txt.toString(), sPeopleArray
    extractPlaces txt.toString(), sPlaceArray
    extractOrganizations txt.toString(), sOrganizationArray


  for i in [1...418]
    fileName = pad i, 3
    fileName += ".txt"
    console.log(fileName)
    filename = path.join(__dirname, '../../data/bbc/politics/' + fileName)
    txt = fs.readFileSync filename, 'utf8'
    extractPeople txt.toString(), pPeopleArray
    extractPlaces txt.toString(), pPlaceArray
    extractOrganizations txt.toString(), pOrganizationArray


  for i in [1...402]
    fileName = pad i, 3
    fileName += ".txt"
    console.log(fileName)
    filename = path.join(__dirname, '../../data/bbc/tech/' + fileName)
    txt = fs.readFileSync filename, 'utf8'
    extractPeople txt.toString(), tPeopleArray
    extractPlaces txt.toString(), tPlaceArray
    extractOrganizations txt.toString(), tOrganizationArray


  for i in [1...387]
    fileName = pad i, 3
    fileName += ".txt"
    console.log(fileName)
    filename = path.join(__dirname, '../../data/bbc/entertainment/' + fileName)
    txt = fs.readFileSync filename, 'utf8'
    extractPeople txt.toString(), ePeopleArray
    extractPlaces txt.toString(), ePlaceArray
    extractOrganizations txt.toString(), eOrganizationArray

  fs.writeFileSync('bPeopleArray.txt',bPeopleArray.join(','), 'utf8')
  fs.writeFileSync('bPlaceArray.txt',bPlaceArray.join(','), 'utf8')
  fs.writeFileSync('bOrganizationArray.txt',bOrganizationArray.join(','), 'utf8')

  fs.writeFileSync('ePeopleArray.txt',ePeopleArray.join(','), 'utf8')
  fs.writeFileSync('ePlaceArray.txt',ePlaceArray.join(','), 'utf8')
  fs.writeFileSync('eOrganizationArray.txt',eOrganizationArray.join(','), 'utf8')

  fs.writeFileSync('sPeopleArray.txt',sPeopleArray.join(','), 'utf8')
  fs.writeFileSync('sPlaceArray.txt',sPlaceArray.join(','), 'utf8')
  fs.writeFileSync('sOrganizationArray.txt',sOrganizationArray.join(','), 'utf8')

  fs.writeFileSync('ePeopleArray.txt',ePeopleArray.join(','), 'utf8')
  fs.writeFileSync('ePlaceArray.txt',ePlaceArray.join(','), 'utf8')
  fs.writeFileSync('eOrganizationArray.txt',eOrganizationArray.join(','), 'utf8')

  fs.writeFileSync('tPeopleArray.txt',tPeopleArray.join(','), 'utf8')
  fs.writeFileSync('tPlaceArray.txt',tPlaceArray.join(','), 'utf8')
  fs.writeFileSync('tOrganizationArray.txt',tOrganizationArray.join(','), 'utf8')

  res.send "Done"

getTags = () ->
  tags  = []
  filename = path.join(__dirname, '../../data/tweetTXT.txt')
  f = fs.readFileSync filename, 'utf8'
  topics = getTopicsfromLDA f.toString()
  tags = topics
  tags

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
  tags = getTags()
  #

  request.get makeQuery(tags), (error, response, body) ->
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
