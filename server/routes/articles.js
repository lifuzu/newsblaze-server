var express = require('express');
var router = express.Router();
var mongo = require('mongoskin');
var article = require('../lib/db.js');
var db = mongo.db('mongodb://@localhost:27017/newsblaze', {native_parser: true});
var collectionName = 'articles';

router.param('collectionName', function(req, res, next, collectionName) {
    req.collection = db.collection(collectionName)
    return next()
})

/* GET collections listing. */
router.get('/', function(req, res, next) {
  db.collection(collectionName).find({}, {limit:60, sort: [['nid', -1]]}).toArray(function(e, results) {
    if (e) return next(e)

    res.json({'articles': results})
  })
});

module.exports = router;
