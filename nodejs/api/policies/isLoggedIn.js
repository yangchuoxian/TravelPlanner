module.exports = function (req, res, next) {
	if (Toolbox.isRequestFromMobileDevice(req.url)) {	// http request is from mobile native app
		var loginToken = req.param('loginToken');
		var currentUserId = req.param('currentUserId');
		if (!currentUserId || !loginToken) {
			return res.badRequest(sails.__('Insufficient permission'));
		} else {
			loginToken = loginToken.trim();
			currentUserId = currentUserId.trim();
			User.findOne({
				// Validate mobile user login status by checking if
				// submitted current user id and submitted loginToken matches
				id: currentUserId,
				loginToken: loginToken
			}, function (err, foundUser) {
				if (err) {
					return res.serverError(err);
				}
				if (foundUser) {
					return next();
				} else {
					return res.badRequest(sails.__('Insufficient permission'));
				}
			});
		}
	} else {	// Http request is from browser
		if (req.session.userId) {
			return next();
		}
		// User is NOT logged in
		return res.badRequest(sails.__('Insufficient permission'));
	}
};