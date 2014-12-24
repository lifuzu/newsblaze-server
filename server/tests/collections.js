var superagent = require('superagent')
var expect = require('expect.js')

var collections = describe('news blaze REST api server - collections', function() {
  var id, url = "http://localhost:3003/collections"

  it('post object', function(done) {
    superagent.post(url + '/cooking')
    .send({title: 'How to cooking something', content: 'How to cooking something with details!'})
    .end(function(e, res) {
      // console.log(res.body)
      expect(e).to.eql(null)
      expect(res.body.length).to.eql(1)
      expect(res.body[0]._id.length).to.eql(24)
      id = res.body[0]._id
      done()
    })
  })

  it('retrieve an object', function(done) {
    superagent.get(url + '/cooking/' + id)
    .end(function(e, res){
      // console.log(res.body)
      expect(e).to.eql(null)
      expect(typeof res.body).to.eql('object')
      expect(res.body._id.length).to.eql(24)
      expect(res.body._id).to.eql(id)
      done()
     })
  })

  it('updates an object', function(done){
    superagent.put(url + '/cooking/' + id)
      .send({title: 'How to cooking other things'
        , content: 'How to cooking other things with details!'})
      .end(function(e, res){
        // console.log(res.body)
        expect(e).to.eql(null)
        expect(typeof res.body).to.eql('object')
        expect(res.body.msg).to.eql('success')
        done()
      })
  })

  it('checks an updated object', function(done){
    superagent.get(url + '/cooking/' + id)
      .end(function(e, res){
        // console.log(res.body)
        expect(e).to.eql(null)
        expect(typeof res.body).to.eql('object')
        expect(res.body._id.length).to.eql(24)
        expect(res.body._id).to.eql(id)
        expect(res.body.title).to.eql('How to cooking other things')
        done()
      })
  })

  it('remove an object', function(done) {
    superagent.del(url + '/cooking/' + id)
    .end(function(e, res) {
      // console.log(res.body)
      expect(e).to.eql(null)
      expect(typeof res.body).to.eql('object')
      expect(res.body.msg).to.eql('success')
      done()
    })
  })
})

module.exports = collections