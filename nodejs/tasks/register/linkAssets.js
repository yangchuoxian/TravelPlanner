module.exports = function (grunt) {
	grunt.registerTask('linkAssets', [
		'sails-linker:devAdminJs',
		'sails-linker:devAdminStyles'
	]);
};
