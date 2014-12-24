mongo = require('mongoskin')

save_article = (article, cb) ->
  db = mongo.db("mongodb://@localhost:27017/newsblaze", {native_parser: true, auto_reconnect: true, poolSize: 1000})
  db.open (e, db) ->
    return cb(true, e) if e
    db.collection('articles').find({origin_link: article.origin_link}).toArray (e, results) ->
      return cb(true, e) if e
      if results.length is 0
        # now = moment()
        # article_data = { "created_at": now, "updated_at": now, "url": url, "nid": nid }
        db.collection('articles').insert article, {safe: true, w:1}, (e, results) ->
          return cb(true, e) if e
          db.close()
          return cb(false, "Inserted " + article.origin_link)
      else
        db.close()
        return cb(false, "Existed " + article.origin_link)

module.exports = {
  save_article: save_article,
}