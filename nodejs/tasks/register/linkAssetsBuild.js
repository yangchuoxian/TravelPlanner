module.exports = function (grunt) {
	grunt.registerTask('linkAssetsBuild', [
		'sails-linker:devAdminJsRelative',
		'sails-linker:devAdminStylesRelative',
	]);
};
