#fetch_image.coffee

fs = require('fs')
request = require('request')

fetch_image = (uri, filename, cb) ->
  request.head uri, (err, res, body) ->
    console.log('content-type:', res.headers['content-type']);
    console.log('content-length:', res.headers['content-length']);

    request(uri).pipe(fs.createWriteStream(filename)).on('close', cb);

module.exports = {
  fetch_image: fetch_image,
}