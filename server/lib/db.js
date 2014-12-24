/**
 * Unzip the article from mongo database.
 *
 */
var mongo = require('mongoskin'),
    GridStore = require('mongodb').GridStore,
    fs = require('fs'),
    AdmZip = require('adm-zip');

/**
 * Unzip one article from mongodb to fs.
 * @param {object} article Metadata of the article
 * @param {string} path Where to unzip the article
 * @param {function} cb(error, savedFilename) Return err or saved filename
 *     according to the return of insertion
 *
 */
function unzip_article(article, path, cb) {
    var file_name = article.file_name.replace(/.epub$/, "");
    var targetFile = path + '/' + file_name;
    //console.log("unzip_article: " + targetFile);
    if (fs.existsSync(targetFile)) {
        cb(null, targetFile);
        return;
    }
    var db = mongo.db('mongodb://@localhost:27017/contentstream', {native_parser: true, auto_reconnect: true, poolSize: 1000});
    db.open(function(e, db) {
        if (e) {
            console.log("error in open db");
            return cb(e, null);
        }
        // Unzip the epub file from gridfs of mongo
        GridStore.read(db, article.file_name, function(e, fileData) {
            db.close();
            if (e) {
                return cb(e, null);
            }
            var zip = new AdmZip(fileData);
            try {
                zip.extractAllTo(targetFile, /*overwrite*/true);
            } catch(e) {
                return cb(e, null);
            } 
            return cb(null, targetFile);
        });
    });
}

module.exports = {
  unzip_article: unzip_article,
}
