casper = require('casper').create({
  pageSettings: {
  	loadImages:  false,
  	loadPlugins: false
  }
  #verbose: true, 
  #logLevel: "info"
  })
#mouse = require('mouse').create(casper)
fs = require('fs')
md = require('html-md')

url = casper.cli.get(0) #'http://news.6park.com/newspark/index.php?app=news&act=view&nid=27452'

casper.start url, ()->
  casper.page.injectJs('includes/jquery-1.10.2.min.js');

casper.then ()->
  title = this.evaluate ()->
    $('#newscontent > center:first > h2').text()
  content = this.evaluate ()->
    $('#newscontent > span').remove();
    $('#newscontent > p > script').remove();
    $('a[href*="perm="]').remove();
    $('#news300').remove();
    $('#newscontent > center:last').remove();
    $('#newscontent > table').remove();
    $('#weibozkinfo').remove();
    $('#newscontent > p:last > table').remove();
    $('#newscontent').html()

  #this.echo(title)
  # Beautify the content: remove the space in <strong>, and other tags in html
  content_md = md(content)
  regex = /新闻来源: (.*) 于 (\d{4}-\d{2}-\d{2} \d{1,2}:\d{2}:\d{2})/
  result = content_md.match(regex)
  publisher = result[1] if result? or null
  publish_at = result[2] if result? or null
  #this.echo(publisher)
  #this.echo(publish_at)
  regex_pic = /(!\[.*?\]\()(.+?)(\))/
  result_pic = content_md.match(regex_pic)
  pic_link = result_pic[2] if result_pic? or null
  #this.echo(pic_link)

  # Collect all of the images
  pic_links = []
  regex_pics = /(!\[.*?\]\()(.+?)(\))/g
  result_pics = content_md.match(regex_pics)
  if result_pics?
    for p in result_pics
      do (p) ->
        pex = p.match(regex_pic)
        if pex?
          pic_links.push(pex[2])

  regex_6park = /(www\.6park\.com)/g
  content_md = content_md.replace(regex_6park, '') if content_md.match(regex_6park)

  console.log(JSON.stringify({
    "title": title,
    "publisher": publisher,
    "publish_at": publish_at,
    "pic_link": pic_link,
    "origin_link": url,
    "images": pic_links,
    "content": content_md
    }))


  #writeToFile('content.md', content_md)

writeToFile = (fileName, content)->
  #console.log('Writing to ' + fileName)
  fs.write(fileName, content, 'w');
# Get the URL, click to enter the web page
# Get the DOM block: "<td width="793" valign="top" class="td3" id="newscontent">"
# Get rid of the useless blocks:
# 1. 
# html to md
# save the md file to couchdb

#casper.then ()->  
#  @.capture result

casper.run()



#TODO:
# 1. created_at - date time new Date()
# 2. updated_at - date time
# 3. title  - String - Parse
# 4. publish_at  - date time - Parse
# 5. publisher - String - Parse
# 6. pic_link - URL - parse if have
# 7. origin_link - URL
# 7. content - attachment - String: content.md
#newscontent > center:nth-child(1) > h2
#newscontent > p:nth-child(15) > table