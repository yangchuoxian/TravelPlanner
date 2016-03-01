module.exports = function (req, res, next) {
	if (req.session.userId) {
		User.findOne({id: req.session.userId}, function (err, user) {
			if (err) {
				return res.view('500');
			}
			if (user) {
				Role.findOne({name: 'admin'}, function (err, adminRole) {
					if (err) {
						return res.serverError(err);
					}
					if (adminRole) {
						if (user.role == adminRole.id) {
							return next();
						} else {
							res.locals.layout = 'admin_pages/admin_layout';
							if (!req.xhr) {
								return res.view('admin_pages/insufficient_permission', {
									pageTitle: sails.__('Something wrong'),
									adminViewIndex: sails.config.constants.insufficientPermissionViewIndex
								});
							} else {
								return res.send(401);
							}
						}
					} else {
						return res.notFound();
					}
				});
			} else {
				return res.view('404');
			}
		});
	} else {
		res.locals.layout = 'admin_pages/admin_layout';
		var baseurl = sails.getBaseurl();
		if (!req.xhr) {
			return res.view('admin_pages/login', {
				pageTitle: sails.__('Admin panel login'),
				adminViewIndex: sails.config.constants.adminLoginViewIndex
			});
		} else {
			return res.send(401);
		}
	}
};