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
    nid = url.match(/\d+$/)[0]
    # Check if we already handled
    url_map = { "status": 'will', "created_at": now, "updated_at": now, "url": url, "nid": nid }
    console.log(JSON.stringify(url_map))

    # exec 'casperjs news_article.coffee "' + url + '"', (error, stdout, stderr)->
	   #  console.log('exec error: ' + error) if error
	   #  #console.log('stdout: ' + stdout)
	   #  console.log('stderr: ' + stderr)
	   #  article = JSON.parse(stdout)
	   #  console.log(article)

	    # Create job here to insert article to database

	    # Write the max nid to indicate what we handled

# Read the nid from fs
# For loop 1..100 to try 100 pages here, until get the handled item, then terminate
for i in [1..5]
	do(i) ->
		exec 'casperjs each_entry.coffee ' + i, (error, stdout, stderr)->
		  console.log('exec error: ' + error) if error
		  #console.log('stdout: ' + stdout)
		  console.log('stderr: ' + stderr)
		  urls = JSON.parse(stdout)

		  urls_uniq = underscore.uniq(urls)
		  console.log urls_uniq.length

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
