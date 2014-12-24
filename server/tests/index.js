var superagent = require('superagent')
var expect = require('expect.js')


var index = describe('news blaze REST api server - index', function() {
	var id, url = "http://localhost:3003/"

	it('retrieve the home page', function(done) {
		superagent.get(url)
		.end(function(err, res){
      console.log(res.body)
      expect(err).to.eql(null)
      expect(typeof res.body).to.eql('object')
      done()
     })
	})
})

module.exports = index