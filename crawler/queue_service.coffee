#queue_service.js
exec = require('child_process').exec
save_article = require('./save_article')
fetch_image = require('./fetch_image')
async = require('async')
que = require('kue')
jobs = que.createQueue()

jobs.process 'news_url', (job, done, ctx) ->
  # mongodb.Article.Save(job.data, function(err, message) {
  #   if (err) {
  #     console.log(err);
  #     console.log(message);
  #     throw err;
  #   }
  #   console.log(job.data.id);
  #   console.log(message);
  #   done();
  # });

  console.log(job.data)
  parse_article job.data.url, (e, result) ->
    if e
      console.log(result)
      throw e
    # console.log(result)

    # Ignore to fetch images and modify the urls in content
    # async.every result.images, fetch_image_to_caches, (fetched) ->
    #   if fetched
    #     for uri in result.images
    #       do(uri) ->
    #         filename = uri.substring(uri.lastIndexOf('/') + 1);
    #         result.content = result.content.replace(uri, 'caches/' + filename)
    #     # console.log(result)
    #     save_article.save_article result, (e, message)->
    #       console.log(message)
    #       throw e if e
    #       done()
    save_article.save_article result, (e, message)->
      console.log(message)
      throw e if e
      done()

# jobs.process('topic', function(job, done, ctx){
#   mongodb.Topic.Save(job.data, function(err, message) {
#     if (err) throw err;
#     console.log(message);
#     done();
#   });
# });

process.once 'SIGINT', ( sig ) ->
  jobs.shutdown (err) ->
    console.log( 'Kue is shut down.', err || '' )
    process.exit 0 
  , 5000

que.app.listen 4001

parse_article = (url, cb) ->
  exec 'casperjs news_article.coffee "' + url + '"', (error, stdout, stderr)->
    return cb(true, error) if error
    #console.log('stdout: ' + stdout)
    return cb(true, stderr) if stderr
    article = JSON.parse(stdout)
    # Add nid for sorting
    nid = url.match(/\d+$/)[0]
    article['nid'] = nid
    return cb(false, article)

fetch_image_to_caches = (uri, cb) ->
  filename = uri.substring(uri.lastIndexOf('/') + 1);
  fetch_image.fetch_image uri, '../server/public/caches/' + filename, () ->
    cb(true)