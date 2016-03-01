/**
 * grunt/pipeline.js
 *
 * The order in which your css, javascript, and template files should be
 * compiled and linked from your views and static HTML files.
 *
 * (Note that you can take advantage of Grunt-style wildcard/glob/splat expressions
 * for matching multiple files.)
 */



// CSS files to inject in order
//
// (if you're using LESS with the built-in default config, you'll want
//  to change `assets/styles/importer.less` instead.)
var adminCssFilesToInject = [
  'styles/admin/*.css'
];


// Client-side javascript files to inject in order
// (uses Grunt-style wildcard/glob/splat expressions)
var adminJsFilesToInject = [
  // the order matters, or the browser may conplaing: 'angular not defined'
  'js/admin/lib/angular.js',
  'js/admin/lib/angular-animate.js',
  'js/admin/lib/angular-file-upload.js',
  'js/admin/lib/angular-ui-router.js',
  'js/admin/lib/datepicker.min.js',
  'js/admin/lib/ui-bootstrap-tpls.js',
  'js/admin/admin_values.js',
  'js/admin/admin_config.js',
  'js/admin/admin_directives.js',
  '/js/admin/admin_services.js',
  'js/admin/admin_controllers.js'
];


// Client-side HTML templates are injected using the sources below
// The ordering of these templates shouldn't matter.
// (uses Grunt-style wildcard/glob/splat expressions)
//
// By default, Sails uses JST templates and precompiles them into
// functions for you.  If you want to use jade, handlebars, dust, etc.,
// with the linker, no problem-- you'll just want to make sure the precompiled
// templates get spit out to the same file.  Be sure and check out `tasks/README.md`
// for information on customizing and installing new tasks.
var templateFilesToInject = [
  'templates/**/*.html'
];

var fontFilesToInject = [
  'styles/fonts/*'
];

// Prefix relative paths to source files so they point to the proper locations
// (i.e. where the other Grunt tasks spit them out, or in some cases, where
// they reside in the first place)
module.exports.adminCssFilesToInject = adminCssFilesToInject.map(function (path) {
  return '.tmp/public/' + path;
});
module.exports.adminJsFilesToInject = adminJsFilesToInject.map(function (path) {
  return '.tmp/public/' + path;
});
module.exports.fontFilesToInject = fontFilesToInject.map(function (path) {
  return '.tmp/public/' + path;
});
module.exports.templateFilesToInject = templateFilesToInject.map(function (path) {
  return 'assets/' + path;
});
