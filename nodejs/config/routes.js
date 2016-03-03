/**
 * Route Mappings
 * (sails.config.routes)
 *
 * Your routes map URLs to views and controllers.
 *
 * If Sails receives a URL that doesn't match any of the routes below,
 * it will check for matching files (images, scripts, stylesheets, etc.)
 * in your assets directory.  e.g. `http://localhost:1337/images/foo.jpg`
 * might match an image file: `/assets/images/foo.jpg`
 *
 * Finally, if those don't match either, the default 404 handler is triggered.
 * See `api/responses/notFound.js` to adjust your app's 404 logic.
 *
 * Note: Sails doesn't ACTUALLY serve stuff from `assets`-- the default Gruntfile in Sails copies
 * flat files from `assets` to `.tmp/public`.  This allows you to do things like compile LESS or
 * CoffeeScript for the front-end.
 *
 * For more information on configuring custom routes, check out:
 * http://sailsjs.org/#!/documentation/concepts/Routes/RouteTargetSyntax.html
 */

module.exports.routes = {

  /***************************************************************************
  *                                                                          *
  * Make the view located at `views/homepage.ejs` (or `views/homepage.jade`, *
  * etc. depending on your default view engine) your home page.              *
  *                                                                          *
  * (Alternatively, remove this and add an `index.html` file in your         *
  * `assets` directory)                                                      *
  *                                                                          *
  ***************************************************************************/

  '/': {
    view: 'homepage'
  },
  /**
   * routes for common views
   */
  'get /404': {view: '404'},
  'get /500': {view: '500'},
  'get /403': {view: '403'},
  /**
   * routes for admin views
   */
  'get /admin': 'ViewController.showAdminPanelView',
  'get /insufficient_permission': 'ViewController.showInsufficientPermissionView',
  'get /admin_login': 'ViewController.showAdminLoginView', 
  /**
   * Routes for user model CRUD
   */
  // Requests from browser
  'post /submit_login': 'UserController.submitLogin',
  'get /logout': 'UserController.logout',
  'get /get_user_roles': 'UserController.getAllUserRoles',
  'get /get_users': 'UserController.getUsersWithCriteria',
  'get /search_users': 'UserController.getUsersWithCriteria',
  'get /order_users': 'UserController.getUsersWithCriteria',
  'get /get_users_with_role': 'UserController.getUsersWithCriteria',
  'get /get_user_info': 'UserController.getUserInfo',
  'post /delete_user': 'UserController.deleteUser',
  'post /update_user_role': 'UserController.updateUserRole',
  'post /update_basic_user_info': 'UserController.updateBasicUserInfo',
  'post /upload_user_avatar': 'UserController.uploadUserAvatar',
  'get /user_avatar': 'UserController.getUserAvatar',
  'post /submit_new_user': 'UserController.submitNewUser',
  // Requests from mobile
  'post /mobile/submit_login': 'UserController.submitLogin',
  'post /mobile/update_user': 'UserController.updateUser',
  'post /mobile/change_user_password': 'UserController.changeUserPassword',
  'post /mobile/upload_user_avatar': 'UserController.uploadUserAvatar',
  'post /mobile/submit_new_user': 'UserController.submitNewUser',
  'get /mobile/user_avatar': 'UserController.getUserAvatar',
  'get /mobile/get_user_info': 'UserController.getUserInfo',
  'get /mobile/logout': 'UserController.logout',
  /**
   * Routes for schedule model CRUD
   */
   // Requests from browser
  'get /get_schedules': 'ScheduleController.getSchedulesWithCriteria',
  'get /get_schedule_info': 'ScheduleController.getSchedule',
  'get /search_schedules': 'ScheduleController.getSchedulesWithCriteria',
  'get /order_schedules': 'ScheduleController.getSchedulesWithCriteria',
  'post /delete_schedule': 'ScheduleController.deleteSchedule',
  'post /submit_new_schedule': 'ScheduleController.submitNewSchedule',
  'post /update_basic_schedule_info': 'ScheduleController.updateBasicScheduleInfo',
  // Requests from mobile
  'get /mobile/filter_schedules': 'ScheduleController.filterSchedules',
  'get /mobile/search_schedules': 'ScheduleController.searchSchedules',
  'post /mobile/change_schedule': 'ScheduleController.changeSchedule',
  'post /mobile/delete_user_schedule': 'ScheduleController.deleteUserSchedule',
  'post /mobile/create_new_schedule': 'ScheduleController.createNewSchedule',
};
