casper = require('casper').create({
  #verbose: true, 
  #logLevel: "debug"
  })

page = casper.cli.get(0)

url_base = 'http://news.6park.com/newspark'
url_page = url_base + '?p=' + page

#links = (url_page + i for i in [446..450])

casper.start url_page, ()->
  #require('utils').dump(this.getElementsAttribute('a[href*="index.php?app=news&act=view"]', 'href'))
  urls = this.getElementsAttribute('a[href*="index.php?app=news&act=view"]', 'href')
  absolute_urls = ( url_base + '/' + url for url in urls)
  console.log(JSON.stringify(absolute_urls[1..]))
# casper.start().each links, (self, link)->
#   this.echo(link)
#   self.thenOpen link, ()->
#     urls = this.getElementsAttribute 'a[href*="index.php?app=news&act=view"]', 'href'
#     absolute_urls = ( url_base + url for url in urls)
#     #require('utils').dump(absolute_urls[1..])
#     console.log(JSON.stringify(absolute_urls[1..]))

casper.run();
