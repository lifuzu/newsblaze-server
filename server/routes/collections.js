var express = require('express');
var router = express.Router();
var mongo = require('mongoskin');
var db = mongo.db('mongodb://@localhost:27017/newsblaze', {native_parser: true});

router.param('collectionName', function(req, res, next, collectionName) {
    req.collection = db.collection(collectionName)
    return next()
})

router.get('/', function(req, res, next) {
	res.send('please select a collection, e.g. /collections/cooking')
})

/* GET collections listing. */
router.get('/:collectionName', function(req, res, next) {
	req.collection.find({}, {limit:10, sort: [['_id', -1]]}).toArray(function(e, results) {
		if (e) return next(e)
		res.send(results)
	})
});

/* POST to create a collection. */
router.post('/:collectionName', function(req, res, next) {
	req.collection.insert(req.body, {}, function(e, results) {
		if (e) return next(e)
		res.send(results)
	})
})

/* GET to get a collection. */
router.get('/:collectionName/:id', function(req, res, next) {
	req.collection.findById(req.params.id, function(e, results) {
		if (e) return next(e)
		res.send(results)
	})
})

/* PUT to update a collection. */
router.put('/:collectionName/:id', function(req, res, next) {
	req.collection.updateById(req.params.id, {$set:req.body}, {safe:true, multi:false}, function(e, results) {
		if (e) return next(e)
		res.send((results === 1)?{msg:'success'}:{msg:'error'})
	})
})

/* DELETE to delete a collection. */
router.delete('/:collectionName/:id', function(req, res, next) {
	req.collection.removeById(req.params.id, function(e, results) {
		if (e) return next(e)
		res.send((results === 1)?{msg:'success'}:{msg:'error'})
	})
})

module.exports = router;
