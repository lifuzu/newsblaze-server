exec = require('child_process').exec
underscore = require('underscore')
lodash = require('lodash')
async = require('async')
moment = require('moment')
uuid = require('node-uuid')
queue = require('kue')
jobs = queue.createQueue({disableSearch:true})

create_job = (url, cb) ->
  job = jobs.create('news_url', url).attempts(5).save (err) ->
    if err
      console.log("error in push to queue")
      return cb(err)

    console.log(url)
    cb(true)

urls_insert = (urls) ->
  # underscore.map urls, (url)->
  async.every urls, create_job, (result)->
    # create_job jobs, {'url': url}, (e)->
    #   console.log(e) if e
    if result is true
      jobs.shutdown (e)->
        console.log(e) if e
        console.log('shutdown exit!')
      , 5000
      console.log("Done!")

    # now = moment()
    # nid = url.match(/\d+$/)[0]
    # # Check if we already handled
    # url_map = { "status": 'will', "created_at": now, "updated_at": now, "url": url, "nid": nid }
    # console.log(JSON.stringify(url_map))

    # exec 'casperjs news_article.coffee "' + url + '"', (error, stdout, stderr)->
     #  console.log('exec error: ' + error) if error
     #  #console.log('stdout: ' + stdout)
     #  console.log('stderr: ' + stderr)
     #  article = JSON.parse(stdout)
     #  console.log(article)

      # Create job here to insert article to database

      # Write the max nid to indicate what we handled

# Read the nid from fs
urls = []
# For loop 1..100 to try 100 pages here, until get the handled item, then terminate
for i in [1..5]
  do(i) ->
    exec 'casperjs each_entry.coffee ' + i, (error, stdout, stderr)->
      console.log('exec error: ' + error) if error
      #console.log('stdout: ' + stdout)
      console.log('stderr: ' + stderr) if stderr
      urls = lodash.union(urls, JSON.parse(stdout))

      urls_uniq = lodash.uniq(urls, true)

      if i is 5
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
