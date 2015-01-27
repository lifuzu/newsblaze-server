/**
 * start http server at :4000
 * allow user to monitor kue status using browser
 */
var que = require('kue');
que.app.listen(4000);
