###
ViewController

@description :: Server-side logic for managing views
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports =
    showAdminLoginView: (req, res) ->
        res.locals.layout = 'admin_pages/admin_layout'
        res.view 'admin_pages/login',
            pageTitle: sails.__ 'Admin panel login'
            previousURL: ''
            adminViewIndex: sails.config.constants.adminLoginViewIndex

    # Insufficient permission view
    showInsufficientPermissionView: (req, res) ->
        res.locals.layout = 'admin_pages/admin_layout'
        res.locals.pageTitle = sails.__ 'Something wrong'
        res.locals.adminViewIndex = sails.config.constants.insufficientPermissionViewIndex
        res.view 'admin_pages/insufficient_permission'

    # Admin base view
    showAdminPanelView: (req, res) ->
        res.locals.layout = 'admin_pages/admin_layout'
        res.locals.pageTitle = sails.__ 'Admin panel'
        res.locals.adminViewIndex = sails.config.constants.adminPanelViewIndex
        res.view 'admin_pages/admin_panel'

