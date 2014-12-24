var fs = require('fs');

module.exports = {
	/**
   * Get the content from the version file.
   *
   * @param  {String} filename
   * @return {String} the content of the filename
   */
	getVersion: function(filename) {
		return ""+fs.readFileSync(filename)
	}
}
