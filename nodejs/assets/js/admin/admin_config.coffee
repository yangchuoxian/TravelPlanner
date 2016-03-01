app = angular.module 'vt-admin-app', ['ngAnimate', 'ui.router', 'ui.bootstrap', 'angularFileUpload', 'datePicker', 'vtValues', 'vtDirectives', 'vtServices']
app.config ['$interpolateProvider', '$httpProvider', '$stateProvider', '$urlRouterProvider',
    ($interpolateProvider, $httpProvider, $stateProvider, $urlRouterProvider) ->
        # Header revision to make sure backend can receive ajax get/post parameters
        csrfToken = document.getElementsByName('csrf-token')[0]
        $httpProvider.defaults.headers.common['X-CFRF-Token'] = csrfToken.content
        $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
        # ui router setup
        $stateProvider
            # dashboard state
            .state 'dashboard',
                url: '/dashboard'
                templateUrl: '/templates/admin/dashboard.html'
                controller: 'DashboardController'
            # user management states
            .state 'user_list',
                url: '/user_list'
                templateUrl: '/templates/admin/user_management/user_list.html'
                controller: 'UserListController'
            .state 'user_profile',
                url: '/user_profile/:userId'
                templateUrl: '/templates/admin/user_management/user_profile.html'
                controller: 'UserProfileController'
            .state 'new_user',
                url: '/new_user'
                templateUrl: '/templates/admin/user_management/new_user.html'
                controller: 'NewUserController'
            .state 'schedule_list',
                url: '/schedule_list'
                templateUrl: '/templates/admin/schedule_management/schedule_list.html'
                controller: 'ScheduleListController'
            .state 'schedule_detail',
                url: '/schedule_detail/:scheduleId'
                templateUrl: '/templates/admin/schedule_management/schedule_detail.html'
                controller: 'ScheduleDetailController'
            .state 'new_schedule',
                url: '/new_schedule'
                templateUrl: '/templates/admin/schedule_management/new_schedule.html'
                controller: 'NewScheduleController'
]