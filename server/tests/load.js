var loadtest = require('loadtest')
var expect = require('expect.js')


var load = describe('news blaze REST api server - load test', function() {
	var options = {
		url: "http://localhost:3003/",
		maxRequests: 1000,
		requestsPerSecond: 100,
		concurrency: 10
	};

	it('load the home page', function(done) {
		loadtest.loadTest(options, function(err, res){
      expect(err).to.eql(null)
      expect(res.percentiles['99']).to.lessThan(50)
      done()
    })
	})
})

module.exports = load
