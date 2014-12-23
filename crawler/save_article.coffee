mongo = require('mongoskin')

save_url = (url, cb) ->
	db = mongo.db("mongodb://@localhost:27017/newsblaze", {native_parser: true, auto_reconnect: true, poolSize: 1000})
	db.open (e, db) ->
		return cb(e, null) if e isnt null
		nid = url.match(/\d+$/)[0]
		db.collection('urls').find({nid: nid}).toArray (e, results) ->
			return cb(e, null) if e isnt null
			if results.length isnt 0
				return cb(true, "Existed!")
			now = moment()
			url_data = { "status": 'new', "created_at": now, "updated_at": now, "url": url, "nid": nid }
			db.collection('urls').insert url_data, {safe: true, w:1}, (e, results) ->
				return cb(e, null) if e isnt null
				db.close
				return cb(null, "Inserted " + url)