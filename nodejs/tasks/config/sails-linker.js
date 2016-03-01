/**
 * Autoinsert script tags (or other filebased tags) in an html file.
 *
 * ---------------------------------------------------------------
 *
 * Automatically inject <script> tags for javascript files and <link> tags
 * for css files.  Also automatically links an output file containing precompiled
 * templates using a <script> tag.
 *
 * For usage docs see:
 * 		https://github.com/Zolmeister/grunt-sails-linker
 *
 */
module.exports = function(grunt) {

	grunt.config.set('sails-linker', {
		devAdminJs: {
		    options: {
		        startTag: '<!--SCRIPTS-->',
		        endTag: '<!--SCRIPTS END-->',
		        fileTmpl: '<script src="%s"></script>',
		        appRoot: '.tmp/public'
		    },
		    files: {
		        'views/admin_pages/*.html': require('../pipeline').adminJsFilesToInject,
		        'views/admin_pages/*.ejs': require('../pipeline').adminJsFilesToInject
		    }
		},
		devAdminJsRelative: {
		    options: {
		        startTag: '<!--SCRIPTS-->',
		        endTag: '<!--SCRIPTS END-->',
		        fileTmpl: '<script src="%s"></script>',
		        appRoot: '.tmp/public',
		        relative: true
		    },
		    files: {
		        'views/admin_pages/*.html': require('../pipeline').adminJsFilesToInject,
		        'views/admin_pages/*.ejs': require('../pipeline').adminJsFilesToInject
		    }
		},

		prodAdminJs: {
		    options: {
		        startTag: '<!--SCRIPTS-->',
		        endTag: '<!--SCRIPTS END-->',
		        fileTmpl: '<script src="%s"></script>',
		        appRoot: '.tmp/public'
		    },
		    files: {
		        'views/admin_pages/*.html': ['.tmp/public/js/admin/production.admin.min.js'],
		        'views/admin_pages/*.ejs': ['.tmp/public/js/admin/production.admin.min.js']
		    }
		},
		prodAdminJsRelative: {
		    options: {
		        startTag: '<!--SCRIPTS-->',
		        endTag: '<!--SCRIPTS END-->',
		        fileTmpl: '<script src="%s"></script>',
		        appRoot: '.tmp/public',
		        relative: true
		    },
		    files: {
		        'views/admin_pages/*.html': ['.tmp/public/js/admin/production.admin.min.js'],
		        'views/admin_pages/*.ejs': ['.tmp/public/js/admin/production.admin.min.js']
		    }
		},

		devAdminStyles: {
		    options: {
		        startTag: '<!--STYLES-->',
		        endTag: '<!--STYLES END-->',
		        fileTmpl: '<link rel="stylesheet" href="%s">',
		        appRoot: '.tmp/public'
		    },

		    files: {
		        'views/admin_pages/*.html': require('../pipeline').adminCssFilesToInject,
		        'views/admin_pages/*.ejs': require('../pipeline').adminCssFilesToInject
		    }
		},
		devAdminStylesRelative: {
		    options: {
		        startTag: '<!--STYLES-->',
		        endTag: '<!--STYLES END-->',
		        fileTmpl: '<link rel="stylesheet" href="%s">',
		        appRoot: '.tmp/public',
		        relative: true
		    },

		    files: {
		        'views/admin_pages/*.html': require('../pipeline').adminCssFilesToInject,
		        'views/admin_pages/*.ejs': require('../pipeline').adminCssFilesToInject
		    }
		},

		prodAdminStyles: {
		    options: {
		        startTag: '<!--STYLES-->',
		        endTag: '<!--STYLES END-->',
		        fileTmpl: '<link rel="stylesheet" href="%s">',
		        appRoot: '.tmp/public'
		    },
		    files: {
		        'views/admin_pages/*.html': ['.tmp/public/styles/admin/production.admin.min.css'],
		        'views/admin_pages/*.ejs': ['.tmp/public/styles/admin/production.admin.min.css']
		    }
		},
		prodAdminStylesRelative: {
		    options: {
		        startTag: '<!--STYLES-->',
		        endTag: '<!--STYLES END-->',
		        fileTmpl: '<link rel="stylesheet" href="%s">',
		        appRoot: '.tmp/public',
		        relative: true
		    },
		    files: {
		        'views/admin_pages/*.html': ['.tmp/public/styles/admin/production.admin.min.css'],
		        'views/admin_pages/*.ejs': ['.tmp/public/styles/admin/production.admin.min.css']
		    }
		},

		// Bring in JST template object
		devTpl: {
			options: {
				startTag: '<!--TEMPLATES-->',
				endTag: '<!--TEMPLATES END-->',
				fileTmpl: '<script type="text/javascript" src="%s"></script>',
				appRoot: '.tmp/public'
			},
			files: {
				'.tmp/public/index.html': ['.tmp/public/jst.js'],
				'views/**/*.html': ['.tmp/public/jst.js'],
				'views/**/*.ejs': ['.tmp/public/jst.js']
			}
		},

		devJsJade: {
			options: {
				startTag: '// SCRIPTS',
				endTag: '// SCRIPTS END',
				fileTmpl: 'script(src="%s")',
				appRoot: '.tmp/public'
			},
			files: {
				'views/**/*.jade': require('../pipeline').jsFilesToInject
			}
		},

		devJsRelativeJade: {
			options: {
				startTag: '// SCRIPTS',
				endTag: '// SCRIPTS END',
				fileTmpl: 'script(src="%s")',
				appRoot: '.tmp/public',
				relative: true
			},
			files: {
				'views/**/*.jade': require('../pipeline').jsFilesToInject
			}
		},

		prodJsJade: {
			options: {
				startTag: '// SCRIPTS',
				endTag: '// SCRIPTS END',
				fileTmpl: 'script(src="%s")',
				appRoot: '.tmp/public'
			},
			files: {
				'views/**/*.jade': ['.tmp/public/min/production.min.js']
			}
		},

		prodJsRelativeJade: {
			options: {
				startTag: '// SCRIPTS',
				endTag: '// SCRIPTS END',
				fileTmpl: 'script(src="%s")',
				appRoot: '.tmp/public',
				relative: true
			},
			files: {
				'views/**/*.jade': ['.tmp/public/min/production.min.js']
			}
		},

		devStylesJade: {
			options: {
				startTag: '// STYLES',
				endTag: '// STYLES END',
				fileTmpl: 'link(rel="stylesheet", href="%s")',
				appRoot: '.tmp/public'
			},

			files: {
				'views/**/*.jade': require('../pipeline').cssFilesToInject
			}
		},

		devStylesRelativeJade: {
			options: {
				startTag: '// STYLES',
				endTag: '// STYLES END',
				fileTmpl: 'link(rel="stylesheet", href="%s")',
				appRoot: '.tmp/public',
				relative: true
			},

			files: {
				'views/**/*.jade': require('../pipeline').cssFilesToInject
			}
		},

		prodStylesJade: {
			options: {
				startTag: '// STYLES',
				endTag: '// STYLES END',
				fileTmpl: 'link(rel="stylesheet", href="%s")',
				appRoot: '.tmp/public'
			},
			files: {
				'views/**/*.jade': ['.tmp/public/min/production.min.css']
			}
		},

		prodStylesRelativeJade: {
			options: {
				startTag: '// STYLES',
				endTag: '// STYLES END',
				fileTmpl: 'link(rel="stylesheet", href="%s")',
				appRoot: '.tmp/public',
				relative: true
			},
			files: {
				'views/**/*.jade': ['.tmp/public/min/production.min.css']
			}
		},

		// Bring in JST template object
		devTplJade: {
			options: {
				startTag: '// TEMPLATES',
				endTag: '// TEMPLATES END',
				fileTmpl: 'script(type="text/javascript", src="%s")',
				appRoot: '.tmp/public'
			},
			files: {
				'views/**/*.jade': ['.tmp/public/jst.js']
			}
		}
	});

	grunt.loadNpmTasks('grunt-sails-linker');
};
