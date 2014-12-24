var express = require('express');
var router = express.Router();
var mongo = require('mongoskin');
var article = require('../lib/db.js');
var db = mongo.db('mongodb://@localhost:27017/newsblaze', {native_parser: true});
var collectionName = 'topics';

router.param('collectionName', function(req, res, next, collectionName) {
    req.collection = db.collection(collectionName)
    return next()
})

/* GET collections listing of topics */
router.get('/', function(req, res, next) {
  // res.send('please select a topic, e.g. /articles/kids')
  db.collection(collectionName).find({}, {}).toArray(function(e, results) {
    if (e) return next(e)
    res.json({'topics': results[0].names})
  })
})

module.exports = router;
