exec = require('child_process').exec
underscore = require('underscore')
moment = require('moment')
uuid = require('node-uuid')
nano = require('nano')('http://localhost:5984')
database = nano.use('news_entries')

db_insert = (database, id, map) ->
  database.insert map, id, (error, body, header)->
    console.log('Error: Inserting ' + map + ' to ' + id, error.reason) if error
  console.log('Info: Inserted ' + map + ' to ' + id + '!' )

db_update = (database, id, update_map) ->
  database.get id, (error, body) ->
    if error # the document has NOT been created
      console.log("Error: Getting " + id, error.reason)
      return false
    map = body
    for own key, value of update_map
      map[key] = value
    map['updated_at'] = moment()
    database.insert map, id, (error, body, header)->
      console.log('Error: Updating ' + map + ' to ' + id, error.reason) if error
    console.log('Info: Updated ' + map + ' to ' + id + '!' )

urls_insert = (urls) ->
  underscore.map urls, (url)->
    now = moment()
    url_map = { "status": 'will', "created_at": now, "updated_at": now }
    #console.log(JSON.stringify(url_map))

    database.head url, (error, _, header)->
      if error # if not, insert it
        db_insert database, url, url_map
      else
        console.log('Warning: URL ' + url + ' already exists!')
        process.exit(1)

# urls = [
#   "http://news.6park.com/newspark/index.php?app=news&act=view&nid=27554"
#   "http://news.6park.com/newspark/index.php?app=news&act=view&nid=27544"
#   "http://news.6park.com/newspark/index.php?app=news&act=view&nid=27543"
#   "http://news.6park.com/newspark/index.php?app=news&act=view&nid=27542"
# ]

exec 'casperjs each_entry.coffee', (error, stdout, stderr)->
  console.log('exec error: ' + error) if error
  #console.log('stdout: ' + stdout)
  console.log('stderr: ' + stderr)
  urls = JSON.parse(stdout)

  urls_uniq = underscore.uniq(urls)
  #console.log urls_uniq.length

  urls_insert(urls_uniq)


# status: will | done

# underscore.map urls_uniq, (url)->
#   now = moment()
#   url_map = { "status": 'will', "created_at": now, "updated_at": now }
#   #console.log(JSON.stringify(url_map))

#   database.head url, (error, _, header)->
#     if error # if not, insert it
#       db_insert database, url, url_map
#     else
#       console.log('Warning: URL ' + url + ' already exists!')
#       process.exit(1)
  
  #db_update database, url, { 'status': 'done' }
