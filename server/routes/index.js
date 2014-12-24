var express = require('express');
var router = express.Router();
var git = require('git-rev');

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'News Blaze' });
});

/* GET version. */
router.get('/version', function(req, res) {
  git.tag(function (str) {
    res.json({"version": str})
  })
})

module.exports = router;
