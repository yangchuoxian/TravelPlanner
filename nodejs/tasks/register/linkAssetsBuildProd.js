module.exports = function (grunt) {
	grunt.registerTask('linkAssetsBuildProd', [
		'sails-linker:prodAdminJsRelative',
		'sails-linker:prodAdminStylesRelative',
	]);
};
