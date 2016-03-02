app = angular.module 'vt-admin-app'
app.controller 'AdminBaseController', ['$scope', '$http', '$window', '$rootScope', '$state', 'adminViewIndex', ($scope, $http, $window, $rootScope, $state, adminViewIndex) ->
    $scope.data = {}
    $scope.adminViewIndex = adminViewIndex
    $scope.isAdminMenuCollapsed = 0
    $http.get '/get_user_info'
    .success (response, status, headers, config) -> $scope.data.currentUser = response  # get current logged in user
    .error (response, status, headers, config) -> $scope.data.loginErrorMessage = response
    $scope.toggleAdminMenu = ->
        if $scope.isAdminMenuCollapsed is 1 then $scope.isAdminMenuCollapsed = 0
        else $scope.isAdminMenuCollapsed = 1
    # receive signal about current user's avatar being updated
    unbindAvatarEvent = $rootScope.$on 'avatarUpdated', (event, args) ->
        if args.modelId is $scope.data.currentUser.id then $scope.data.currentUser.avatar = args.avatar
    $scope.$on '$destroy', unbindAvatarEvent        # unregister the listener to the avatar update event
    unbindStateChangeStartEvent = $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) -> $scope.data.isChangingState = true
    $scope.$on '$destroy', unbindStateChangeStartEvent      # unregister the listener to state change start event
    unbindStateChangeSuccessEvent = $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
        $scope.data.isChangingState = false
        switch $state.current.name  # find out current state and set its corresponding currentViewIndex
            when 'dashboard' then $scope.currentViewIndex = adminViewIndex.dashboard
            when 'user_list', 'new_user', 'user_profile' then $scope.currentViewIndex = adminViewIndex.user
            when 'schedule_list', 'new_schedule', 'schedule_detail' then $scope.currentViewIndex = adminViewIndex.schedule
    $scope.$on '$destroy', unbindStateChangeSuccessEvent        # unregister the listener to state change success event
]
app.controller 'LoginController', ['$scope', '$http', '$window', '$location', ($scope, $http, $window, $location) ->
    $scope.data = {}
    $scope.submitAdminLogin = (e) ->
        e.preventDefault()
        csrfToken = document.getElementsByName('csrf-token')[0].content
        $http.post '/submit_login',
            'username': $scope.data.username
            'password': $scope.data.password
            '_csrf': csrfToken
        .success (response, status, headers, config) ->
            if response.role.name is 'admin'
                if $window.location.href.indexOf('admin_login') isnt -1
                    $window.location.href = '/admin#/dashboard'
                else
                    $window.location.href = '/admin#/dashboard'
                    $window.location.reload()
            else $window.location.href = '/'
        .error (response, status, headers, config) -> $scope.data.loginErrorMessage = response
]
app.controller 'UserListController', ['$scope', '$http', '$modal', 'listTypes', 'actionOptions', 'listService', 'paginationService', ($scope, $http, $modal, listTypes, actionOptions, listService, paginationService) ->
    $scope.data = {}
    $scope.data.selectedIds = []
    $scope.paginationService = paginationService
    $scope.listService = listService
    $scope.actionOptions = actionOptions
    $http.get '/get_user_roles'
    .success (response, status, headers, config) -> $scope.data.roles = response
    $scope.data.listType = listService.renewListType '/get_users', listTypes[0].index, listTypes[0].name
    paginationService.getPaginatedModels $scope.data, 1
    $scope.getUsersWithRole = (e, role) ->
        e.preventDefault()
        $scope.data.listType = listService.renewListType '/get_users_with_role', listTypes[4].index, listTypes[4].name + ' - ' + role.name, role.id
        paginationService.getPaginatedModels $scope.data, 1
    # change selected users role to designated role
    $scope.changeUserRole = ->
        return if !$scope.data.selectedRole or $scope.data.selectedIds.length is 0
        modalInstance = $modal.open     # open confirm message box
            templateUrl: 'confirm_modal.html'
            controller: 'ConfirmModalController'
            resolve:
                message: -> 'Are you sure to revise selected item(s)?'
        modalInstance.result.then -> # action has been confirmed
            csrfToken = document.getElementsByName('csrf-token')[0].content
            $http.post '/update_user_role',
                'ids': $scope.data.selectedIds
                'roleId': $scope.data.selectedRole.id
                '_csrf': csrfToken
            .success (response, status, headers, config) ->
                angular.forEach $scope.data.selectedIds, (id, index) ->
                    for i in [0...$scope.data.entries.length]
                        if id is $scope.data.entries[i].id
                            $scope.data.entries[i].role = response
                            break
                $scope.data.selectedIds = []
            .error (response, status, headers, config) ->
                # status 401 means user is either not logged in or doesn't have the authority to make such request
                if status is 401 then $window.location.href = '/insufficient_permission'
]
app.controller 'UserProfileController', ['$scope', '$modal', '$http', '$window', '$stateParams', 'avatarUpload', '$rootScope', 'toolbox', ($scope, $modal, $http, $window, $stateParams, avatarUpload, $rootScope, toolbox) ->
    $scope.data = {}
    $scope.avatarUpload = avatarUpload
    $http.get '/get_user_info', params: 'id': $stateParams.userId
    .success (response, status, headers, config) -> $scope.data.user = response
    .error (response, status, headers, config) ->
        if status is 500 then $window.location.href = '/500'
        else if status is 404 then $window.location.href = '/404'
        else if status is 401 then $window.location.href = '/insufficient_permission'
    $http.get '/get_user_roles'
    .success (response, status, headers, config) -> $scope.data.roles = response
    $scope.submitBasicUserInfo = (e) ->
        e.preventDefault()
        return if $scope.data.password != $scope.data.confirmPassword
        csrfToken = document.getElementsByName('csrf-token')[0].content
        $http.post '/update_basic_user_info',
            'user': $scope.data.user
            'password': $scope.data.password
            '_csrf': csrfToken
        .success (response, status, headers, config) ->
            $scope.data.basicInfoSubmitSucceeded = true
            $scope.data.basicInfoSubmitHintMessage = 'User information successfully updated'
        .error (response, status, headers, config) ->
            if status is 401 then $window.location.href = '/insufficient_permission'
            else if status is 500 or status is 400
                $scope.data.basicInfoSubmitSucceeded = false
                $scope.data.basicInfoSubmitHintMessage = response

]
app.controller 'MessageContentController', ['$scope', 'messageContent', '$modalInstance', ($scope, messageContent, $modalInstance) ->
    $scope.messageContent = messageContent
    $scope.ok = -> $modalInstance.close()
]
app.controller 'NewUserController', ['$scope', '$http', '$window', '$upload', 'avatarUpload', ($scope, $http, $window, $upload, avatarUpload) ->
    $scope.data = {}
    $scope.avatarUpload = avatarUpload
    $scope.data.user = avatar: '/images/default-avatar.jpg'
    $http.get '/get_user_roles'
    .success (response, status, headers, config) -> $scope.data.roles = response
    $scope.submitNewUser = (e) ->
        e.preventDefault()
        if $scope.data.password is $scope.data.confirmPassword
            # the parameter isFromAdmin tells the backend that the new user is created from admin panel, not from new user registration by an actual new user
            csrfToken = document.getElementsByName('csrf-token')[0].content
            $http.post '/submit_new_user',
                'username': $scope.data.user.username
                'email': $scope.data.user.email
                'password': $scope.data.password
                'role': $scope.data.user.role
                'name': $scope.data.user.name
                'phone': $scope.data.user.phoneNumber
                'citizenID': $scope.data.user.citizenID
                'isSubmittedByAdmin': true
                '_csrf': csrfToken
            .success (response, status, headers, config) ->
                $scope.data.user = avatar: '/images/default-avatar.jpg'
                $scope.data.password = $scope.data.confirmPassword = null
                $scope.data.newUserSubmitSucceeded = true
                $scope.data.newUserSubmitHintMessage = 'New user successfully created'
            .error (response, status, headers, config) ->
                if status is 401 then $window.location.href = '/insufficient_permission'
                else if status is 500 or status is 400
                    $scope.data.newUserSubmitSucceeded = false
                    $scope.data.newUserSubmitHintMessage = response
]
app.controller 'ScheduleListController', ['$scope', '$http', '$modal', 'listTypes', 'actionOptions', 'listService', 'paginationService', 'toolbox', ($scope, $http, $modal, listTypes, actionOptions, listService, paginationService, toolbox) ->
    $scope.data = {}
    $scope.data.selectedIds = []
    $scope.timePeriod = {}
    $scope.paginationService = paginationService
    $scope.listService = listService
    $scope.actionOptions = actionOptions
    $scope.data.listType = listService.renewListType '/get_schedules', listTypes[0].index, listTypes[0].name
    paginationService.getPaginatedModels $scope.data, 1
    $scope.showSchedulesWithinTimePeriod = ->
        if $scope.timePeriod.startTime and $scope.timePeriod.endTime
            startTime = toolbox.convertDateTimeString $scope.timePeriod.startTime
            endTime = toolbox.convertDateTimeString $scope.timePeriod.endTime
            $scope.data.listType = listService.renewListType '/get_schedules', listTypes[3].index, listTypes[3].name, null, null, null, null, null, null, null, null, startTime, endTime
            paginationService.getPaginatedModels $scope.data, 1
]
app.controller 'NewScheduleController', ['$scope', '$http', '$window', ($scope, $http, $window) ->
    $scope.data = {}
    $scope.schedule = {}
    $scope.submitNewSchedule = (e) ->
        e.preventDefault()
        csrfToken = document.getElementsByName('csrf-token')[0].content
        $http.post '/submit_new_schedule',
            'cityOfDeparture': $scope.data.schedule.cityOfDeparture
            'cityOfArrival': $scope.data.schedule.cityOfArrival
            'startDate': $scope.data.schedule.startDate
            'endDate': $scope.data.schedule.endDate
            'username': $scope.data.schedule.username
            'comment': $scope.data.schedule.comment
            '_csrf': csrfToken
        .success (response, status, headers, config) ->
            $scope.data.newScheduleSubmitSucceeded = true
            $scope.data.newScheduleSubmitHintMessage = 'New schedule successfully created.'
        .error (response, status, headers, config) ->
            if status is 401 then $window.location.href = '/insufficient_permission'
            else if status is 500 or status is 400
                $scope.data.newScheduleSubmitSucceeded = false
                $scope.data.newScheduleSubmitHintMessage = response
]
app.controller 'ScheduleDetailController', ['$scope', '$http', '$window', '$stateParams', ($scope, $http, $window, $stateParams) ->
    $scope.data = {}
    $http.get '/get_schedule_info', params: 'id': $stateParams.scheduleId
    .success (response, status, headers, config) ->
        $scope.data.schedule = response
        $scope.data.schedule.startDate = new Date $scope.data.schedule.startDate
        $scope.data.schedule.endDate = new Date $scope.data.schedule.endDate
    .error (response, status, headers, config) ->
        if status is 500 then $window.location.href = '/500'
        else if status is 404 then $window.location.href = '/404'
        else if status is 401 then $window.location.href = '/insufficient_permission'
    $scope.submitBasicScheduleInfo = (e) ->
        e.preventDefault()
        csrfToken = document.getElementsByName('csrf-token')[0].content
        $http.post '/update_basic_schedule_info',
            'cityOfDeparture': $scope.data.schedule.cityOfDeparture
            'cityOfArrival': $scope.data.schedule.cityOfArrival
            'startDate': $scope.data.schedule.startDate
            'endDate': $scope.data.schedule.endDate
            'username': $scope.data.schedule.username
            'comment': $scope.data.schedule.comment
            '_csrf': csrfToken
        .success (response, status, headers, config) ->
            $scope.data.scheduleInfoSubmitSucceeded = true
            $scope.data.scheduleInfoSubmitHintMessage = 'Schedule information successfully updated'
        .error (response, status, headers, config) ->
            if status is 401 then $window.location.href = '/insufficient_permission'
            else if status is 500 or status is 400
                $scope.data.scheduleInfoSubmitSucceeded = false
                $scope.data.scheduleInfoSubmitHintMessage = response
]
# Please note that $modalInstance represents a modal window (instance) dependency.
# It is not the same as the $modal service used above.
app.controller 'ConfirmModalController', ['$scope', '$modalInstance', 'message', ($scope, $modalInstance, message) ->
    $scope.message = message
    $scope.ok = -> $modalInstance.close()
    $scope.cancel = -> $modalInstance.dismiss()
]
app.controller 'DashboardController', ['$scope', '$http', ($scope, $http) ->
]