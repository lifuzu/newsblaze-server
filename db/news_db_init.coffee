nano = require('nano')('http://localhost:5984')
nano.db.create('news_entries')
nano.db.create('news_articles')
