exec = require('child_process').exec
underscore = require('underscore')
moment = require('moment')
uuid = require('node-uuid')
nano = require('nano')('http://localhost:5984')
articles = nano.use('news_articles')
entries = nano.use('news_entries')
fs = require('fs')
request = require('request')
mime = require('mime')
http = require('http')

db_insert = (database, id, map, cb) ->
  database.insert map, id, (error, body, header)->
    if error
      console.log('Error: Inserting ' + map + ' to ' + id, error.reason)
      process.exit(-1)
    cb(body)
  console.log('Info: Inserted ' + map + ' to ' + id + '!' )

db_update = (database, id, update_map, cb) ->
  database.get id, (error, body) ->
    if error # the document has NOT been created
      console.log("Error: Getting " + id, error.reason)
      return false
    map = body
    for own key, value of update_map
      map[key] = value
    map['updated_at'] = moment()
    #console.log map
    database.insert map, id, (error, body, header)->
      console.log('Error: Updating ' + map + ' to ' + id, error.reason) if error
    console.log('Info: Updated ' + map + ' to ' + id + '!' )
    cb if cb

download = (uri, file_name, cb) ->
  request.head uri, (error, res, body) ->
    if error
      console.log('Warn: Download ' + uri + ' save to file ' + file_name, error.reason)
      request.head uri, (error, res, body) ->
        if error
          console.log('Error: Download ' + uri + ' save to file ' + file_name, error.reason)
          process.exit(-1)
    # console.log('content-type:', res.headers['content-type'])
    # console.log('content-length:', res.headers['content-length'])
    request(uri).pipe(fs.createWriteStream(file_name)).on('close', cb);

download_image = (uri, file_name, cb) ->
  file = fs.createWriteStream file_name
  request = http.get uri, (res) ->
    res.pipe file
    file.on 'finish', () ->
      file.close cb
  request.on 'error', (error) ->
    fs.unlink file_name
    cb(error) if cb

String.prototype.replaceAll = (search, replacement) ->
  target = this
  target.replace new RegExp(search, 'g'), replacement

# attachment_insert = (database, id, name, data, rev, tried, cb) ->
#   database.attachment.insert id, name, data, mime.lookup(name), { rev: rev }, (error, body) ->
#     if error
#       if (error.error === 'conflict' && tried < 1)
#         return database.get id, (error, body) ->
#           attachment_insert database, id name, data, body['rev'], tried + 1

#       console.log('Error: Insert attachment ' + name + ' to ' + id, error.reason)
#       #cb(error, map['origin_link'])
#     rev = body['rev']

http_pics = (links_pic, regex_pic_only_http) ->


article_insert = (map, cb) ->
  now = moment()
  map['created_at'] = map['updated_at'] = now
  id = uuid.v4()
  data = map['content']
  delete map['content']

  console.log(JSON.stringify(map))

  # parse data to get the links of image
  # regex_pic = /!\[.*?\]\((http.*?([\w\._-]+)\.(jpg|jpeg|png|gif|bmp)?)\)/g
  # links_pic = data.match(regex_pic)
  # console.log(links_pic)
  # regex_pic_only_http = /http.*([\w\._-]+)\.(jpg|jpeg|png|gif|bmp)?/
  # http_pics = (link.match(regex_pic_only_http)[0] for link in links_pic if links_pic?)
  # #console.log(links_pic)
  # regex_pic_file_name = /([\w\._-]+)\.(jpg|jpeg|png|gif|bmp)/
  # name_link_dict = new class then constructor: ->
  #   @[index + '_' + url.match(regex_pic_file_name)[0]] = url for url, index in http_pics if http_pics?
  # console.log(name_link_dict)

  # # replace with the new links
  # for pic_name, pic_link of name_link_dict
  #   do (pic_name, pic_link) ->
  #     # replace the picture link in data (map['content'])
  #     data = data.replaceAll(pic_link, pic_name)
  #     # replace the first pic_link
  #     map['pic_link'] = pic_name if /0_/.test(pic_name)

  db_insert articles, id, map, (body) ->
    articles.attachment.insert id, 'content.md', data, 'text/json', { rev: body['rev'] }, (error, body)->
      if error
        console.log('Error: Insert attachment to ' + id, error.reason)
        cb(error, map['origin_link'])
      console.log('Info: Inserted attachment "content.md" to ' + id + '!')

      # for own pic_name, pic_link of name_link_dict
      #   do (pic_name, pic_link) ->
      #     console.log(pic_link, pic_name)
      #     # download picture from url
      #     download_image pic_link, pic_name, () ->
      #       console.log(pic_link, pic_name)
      #       fs.readFile pic_name, (error, data) ->
      #         if error
      #           console.log('Error: Read file ' + pic_name, error.reason)
      #           cb(error, map['origin_link'])
      #         #attachment_insert articles, id, pic_name, data, rev, 0
      #         articles.get id, (error, body) ->
      #           if error
      #             console.log('Error: Get' + id, error.reason)
      #             cb(error, map['origin_link'])

      #           # database.get should be body['_rev']
      #           articles.attachment.insert id, pic_name, data, mime.lookup(pic_name), { rev: body['_rev'] }, (error, body) ->
      #             if error
      #               console.log('Error: Insert attachment ' + pic_name + ' to ' + id, error.reason)
      #               cb(error, map['origin_link'])
      #             console.log('Info: Inserted attachment ' + pic_name + ' to ' + id + '!')
      #             fs.unlink pic_name, (error) ->
      #               if error
      #                 console.log('Error: Unlink file ' + pic_name, error.reason)
      #                 cb(error, map['origin_link'])
      #               console.log('Info: Remove the file ' + pic_name)

      cb(null, map['origin_link'])

entries_done = (id) ->
  db_update entries, id, {"status": 'done'}

entries_back = (id, cb) ->
  db_update entries, id, {"status": 'will'}, cb

exit = ()->
  process.exit(-1)

crawler = (url) ->
  exec 'casperjs news_one.coffee "' + url + '"', (error, stdout, stderr)->
    console.log('exec error: ' + error) if error
    #console.log('stdout: ' + stdout)
    console.log('stderr: ' + stderr)
    article = JSON.parse(stdout)

    #console.log article

    article_insert article, (error, url)->
      entries_back(url, exit) if error
      entries_done(url)

# main function
entries.view 'views', 'list_status_will_docs', (error, body) ->
  if error
    console.log('Error: List all documents with status \'will\'', error.reason)
    process.exit(-1)
  #body.rows.forEach (doc) ->
  for doc in body.rows
    do (doc) ->
      console.log doc.id
      crawler doc.id

# debug entry
#crawler "http://news.6park.com/newspark/index.php?app=news&act=view&nid=3266"