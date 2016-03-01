app = angular.module 'vtServices', ['angularFileUpload', 'vtValues']
app.service 'toolbox', ['$http', '$window', 'timeUnits', ($http, $window, timeUnits) ->
    this.daysInMonth = (month, year) -> new Date(year, month + 1, 0).getDate()
    this.calculateTimeDiffFromNow = (time) ->
        currentTimeInSeconds = new Date().getTime() / 1000
        theTimeInSeconds = new Date(time).getTime() / 1000
        timeDiffInSeconds = Math.floor(currentTimeInSeconds - theTimeInSeconds)
        if  timeDiffInSeconds < 60 then timeDiffInSeconds + '秒前'   # a few seconds ago, within a minute
        else if  timeDiffInSeconds < 3600 then Math.floor(timeDiffInSeconds / 60) + '分钟前'   # a few minutes ago, within an hour
        else if  timeDiffInSeconds < 24 * 3600 then Math.floor(timeDiffInSeconds / 3600) + '小时前' # a few hours ago, within a day
        else Math.floor(timeDiffInSeconds / (24 * 3600)) + '天前'   # many days ago
    this.getTextExcerpt = (text, numOfCharacters) ->
        if text.length <= numOfCharacters then text
        else text.substring(0, numOfCharacters) + '...'
    this.getWeeksAndDaysInMonth = (currentDate) ->
        month = currentDate.month - 1
        year = currentDate.year
        dateOfToday = new Date()
        numOfDaysInCurrentMonth = this.daysInMonth month, year
        firstDay = new Date year, month, 1
        firstDay.setDate firstDay.getDate() - firstDay.getDay()
        lastDay = new Date year, month, 1
        lastDay.setDate lastDay.getDate() + numOfDaysInCurrentMonth - 1
        lastDay.setDate lastDay.getDate() + timeUnits.numOfDaysInAWeek - lastDay.getDay() - 1
        firstDayString = firstDay.getFullYear() + '-' + parseInt(firstDay.getMonth() + 1) + '-' + firstDay.getDate()
        # when generating lastDayString, need to include the last day of the time period
        lastDayString = lastDay.getFullYear() + '-' + parseInt(lastDay.getMonth() + 2) + '-01'
        day = {}
        week = weeksOfTheMonth = []
        i = firstDay
        while i <= lastDay
            day =
                year: i.getFullYear()
                month: i.getMonth()
                date: i.getDate()
                activities: []
            if day.year == dateOfToday.getFullYear() and day.month == dateOfToday.getMonth() and day.date == dateOfToday.getDate() then day.isToday = true
            if day.month == month then day.isInThisMonth = true
            week.push day
            if week.length == timeUnits.numOfDaysInAWeek
                weeksOfTheMonth.push week
                week = []
            i.setDate i.getDate() + 1
        firstDayString: firstDayString,
        lastDayString: lastDayString,
        weeks: weeksOfTheMonth
    this.convertDateTimeString = (string) ->
        date = new Date string
        month = ("0" + (date.getMonth() + 1)).slice -2
        day = ("0" + date.getDate()).slice -2
        [date.getFullYear(), month, day].join "-"
    this
]
app.service 'avatarUpload', ['$rootScope', '$upload', ($rootScope, $upload) ->
    # AVATAR UPLOADER SETUP
    this.fileSelected = (url, model, controllerData) ->
        if controllerData.chosenImageFile
            # upload file size should be smaller than 2mb
            return controllerData.uploadErrorMessage = 'File size cannot be larger than 2mb' if controllerData.chosenImageFile[0].size > 2000000
            # only one file can be uploaded
            return controllerData.uploadErrorMessage = 'Only one file can be uploaded at one time' if controllerData.chosenImageFile.length > 1
            # supported image file type
            return controllerData.uploadErrorMessage = 'Image file can only be jpg, png or gif format' if controllerData.chosenImageFile[0].type != "image/jpeg" and controllerData.chosenImageFile[0].type != "image/png"
            controllerData.uploadErrorMessage = null
            controllerData.uploadPercentage = '0'
            controllerData.isUploading = true
            csrfToken = document.getElementsByName('csrf-token')[0]
            $upload.upload
                url: url
                method: 'POST'
                fileFormDataName: 'avatar'
                file: controllerData.chosenImageFile
                data:
                    '_csrf': csrfToken.content
                    'fileName': controllerData.chosenImageFile[0].name
                    'modelId': model.id
            .progress (event) -> controllerData.uploadPercentage = parseInt 100.0 * event.loaded / event.total
            .success (response, status, headers, config) ->
                controllerData.isUploading = false
                d = new Date()
                model.avatar = response.avatarUrl + '&' + d.getTime()
                model.id = response.modelId
                $rootScope.$emit 'avatarUpdated', {modelId: model.id, avatar: model.avatar}
    this
]
# list service for database models/objects tables
app.service 'listService', ['$http', '$window', '$modal', 'listTypes', 'paginationService', ($http, $window, $modal, listTypes, paginationService) ->
    this.renewListType = (url, index, name, role, keyword, orderBy, order, teamId, messageStatus, messageType, recipientUserId, startTime, endTime) ->
        listType = {}
        listType.url = url
        listType.index = index
        listType.name = name
        listType.role = role
        listType.keyword = keyword
        listType.orderBy = orderBy
        listType.order = order
        listType.teamId = teamId
        listType.messageStatus = messageStatus
        listType.messageType = messageType
        listType.recipientUserId = recipientUserId
        listType.startTime = startTime
        listType.endTime = endTime
        listType
    # ajax post to delete single model/object in database
    this.deleteEntry = (entry, entryName, controllerData, url) ->
        # open confirm message box
        modalInstance = $modal.open
            templateUrl: 'confirm_modal.html'
            controller: 'ConfirmModalController'
            resolve: message: () -> 'Are you sure to delete ' + '  ' + entryName + '?'
        # action has been confirmed
        modalInstance.result.then ->
            ids = [entry.id]
            csrfToken = document.getElementsByName('csrf-token')[0].content
            $http.post url, {'ids': ids, '_csrf': csrfToken}
            .success (response, status, headers, config) ->
                index = controllerData.entries.indexOf entry
                controllerData.entries.splice index, 1
                # update pagination info and if all entries in current page have been deleted, reload a new page automatically
                controllerData.paginationInfo.total--
                paginationService.calculatePaginationInfo controllerData.paginationInfo, controllerData.entries.length
                if controllerData.entries.length == 0
                    originalCurrentPage = controllerData.paginationInfo.currentPage
                    if originalCurrentPage <= controllerData.paginationInfo.totalPages then paginationService.getPaginatedModels(controllerData, originalCurrentPage)
                    else paginationService.getPaginatedModels controllerData, originalCurrentPage - 1
            .error (response, status, headers, config) ->
                # status 401 means user is either not logged in or doesn't have the authority to make such request
                if status == 401 then $window.location.href = '/insufficient_permission'
    # bulk action to apply the same action to more than one entries
    this.deleteMultipleEntries = (controllerData, url) ->
        return if !controllerData.selectedAction
        if controllerData.selectedAction.value == 1
            if controllerData.selectedIds.length > 0
                # open confirm message box
                modalInstance = $modal.open
                    templateUrl: 'confirm_modal.html'
                    controller: 'ConfirmModalController'
                    resolve:
                        message: -> 'Are you sure to delete selected item(s)?'
                modalInstance.result.then () -> # action has been confirmed
                    csrfToken = document.getElementsByName('csrf-token')[0].content
                    $http.post url, {'ids': controllerData.selectedIds, '_csrf': csrfToken}
                    .success (response, status, headers, config) ->
                        # remove entries in the frontend after successfully delete multiple entries in backend database
                        for i in [0...controllerData.selectedIds.length]
                            for j in [0...controllerData.entries.length]
                                if controllerData.entries[j].id == controllerData.selectedIds[i]
                                    controllerData.entries.splice j, 1
                                    break
                        # update pagination info and if all entries in current page have been deleted, reload a new page automatically
                        controllerData.paginationInfo.total -= controllerData.selectedIds.length
                        paginationService.calculatePaginationInfo controllerData.paginationInfo, controllerData.entries.length
                        controllerData.selectedIds = []
                        if controllerData.entries.length == 0
                            originalCurrentPage = controllerData.paginationInfo.currentPage
                            if originalCurrentPage <= controllerData.paginationInfo.totalPages then paginationService.getPaginatedModels controllerData, originalCurrentPage
                            else paginationService.getPaginatedModels controllerData, originalCurrentPage - 1
                    .error (response, status, headers, config) ->
                        # status 401 means user is either not logged in or doesn't have the authority to make such request
                        if status == 401 then $window.location.href = '/insufficient_permission'
    # select/unselect all entries by pushing/removing entry ids into/from selectedIds[]
    this.selectAllEntries = (controllerData) ->
        if controllerData.selectedIds.length != controllerData.entries.length
            controllerData.selectedIds = []
            angular.forEach controllerData.entries, (entry, index) -> controllerData.selectedIds.push entry.id
        else controllerData.selectedIds = []
    # select/unselect single entry by pushing/rmoving its entry id into/from selectedIds[]
    this.selectEntry = (entry, controllerData) ->
        index = controllerData.selectedIds.indexOf entry.id
        if  index == -1 then controllerData.selectedIds.push entry.id
        else controllerData.selectedIds.splice index, 1
    this.getAll = (e, url, controllerData) ->
        e.preventDefault()
        if controllerData.listType.index != listTypes[0].index
            controllerData.listType = this.renewListType url, listTypes[0].index, listTypes[0].name
            paginationService.getPaginatedModels controllerData, 1
    this.search = (url, controllerData) ->
        controllerData.listType = this.renewListType url, listTypes[1].index, listTypes[1].name + ' - ' + controllerData.keyword, null, controllerData.keyword
        paginationService.getPaginatedModels controllerData, 1
    this.order = (e, orderBy, url, controllerData) ->
        e.preventDefault()
        order = 'asc'
        if controllerData.listType.orderBy == orderBy
            if controllerData.listType.order == 'asc'
                order = 'desc'
        controllerData.listType = this.renewListType url, listTypes[2].index, listTypes[2].name + ' - ' + orderBy + ' - ' + order, null, null, orderBy, order
        paginationService.getPaginatedModels controllerData, 1
    this
]
app.service 'paginationService', ['$http', ($http) ->
    this.getPaginationParams = (page, listType) ->
        params = {}
        params.url = listType.url
        params.queryString =
            'keyword': listType.keyword
            'role': listType.role
            'orderBy': listType.orderBy
            'order': listType.order
            'teamId': listType.teamId
            'messageStatus': listType.messageStatus
            'messageType': listType.messageType
            'recipientUserId': listType.recipientUserId
            'startTime': listType.startTime
            'endTime': listType.endTime,
            'page': page
        params
    this.calculatePaginationInfo = (paginationData, numOfEntriesInCurrentPage) ->
        i = 0
        paginationData.total = parseInt paginationData.total
        paginationData.itemsPerPage = parseInt paginationData.itemsPerPage
        paginationData.currentPage = parseInt paginationData.currentPage
        if numOfEntriesInCurrentPage == 0 then paginationData.fromIndex = paginationData.toIndex = '*'
        else
            paginationData.fromIndex = paginationData.itemsPerPage * (paginationData.currentPage - 1) + 1
            if paginationData.total == 0 then paginationData.fromIndex = 0
            paginationData.toIndex = paginationData.fromIndex + numOfEntriesInCurrentPage - 1
            if paginationData.toIndex > paginationData.total then paginationData.toIndex = paginationData.total
        paginationData.totalPages = Math.ceil paginationData.total / paginationData.itemsPerPage
        paginationData.showingPages = []
        if paginationData.totalPages <= 5 then paginationData.showingPages.push i + 1 for i in [0...paginationData.totalPages]
        else
            if paginationData.currentPage <= 3 then paginationData.showingPages = [1, 2, 3, 4, 5]
            else if (paginationData.totalPages - paginationData.currentPage) <= 2
                paginationData.showingPages.push i for i in [paginationData.totalPages - 4...paginationData.totalPages + 1]
            else paginationData.showingPages.push i for i in [paginationData.currentPage - 2...paginationData.currentPage + 3]
                    
    this.getPaginatedModels = (data, page) ->
        paginationParams = this.getPaginationParams page, data.listType
        $http.get paginationParams.url, {params: paginationParams.queryString}
        .success (response, status, headers, config) ->
            data.entries = response.models
            data.paginationInfo = response.paginationInfo
            i = 0
            data.paginationInfo.total = parseInt data.paginationInfo.total
            data.paginationInfo.itemsPerPage = parseInt data.paginationInfo.itemsPerPage
            data.paginationInfo.currentPage = parseInt data.paginationInfo.currentPage
            data.paginationInfo.fromIndex = data.paginationInfo.itemsPerPage * (data.paginationInfo.currentPage - 1) + 1
            if data.paginationInfo.total == 0 then data.paginationInfo.fromIndex = 0
            data.paginationInfo.toIndex = data.paginationInfo.fromIndex + data.paginationInfo.itemsPerPage - 1
            if data.paginationInfo.toIndex > data.paginationInfo.total then data.paginationInfo.toIndex = data.paginationInfo.total
            data.paginationInfo.totalPages = Math.ceil data.paginationInfo.total / data.paginationInfo.itemsPerPage
            data.paginationInfo.showingPages = []
            if data.paginationInfo.totalPages <= 5
                data.paginationInfo.showingPages.push i + 1 for i in [0...data.paginationInfo.totalPages]
            else
                if data.paginationInfo.currentPage <= 3
                    data.paginationInfo.showingPages = [1, 2, 3, 4, 5]
                else if (data.paginationInfo.totalPages - data.paginationInfo.currentPage) <= 2
                    data.paginationInfo.showingPages.push i for i in [data.paginationInfo.totalPages - 4...data.paginationInfo.totalPages + 1]
                else data.paginationInfo.showingPages.push i for i in [data.paginationInfo.currentPage - 2...data.paginationInfo.currentPage + 3]
    this.firstPage = (e, data) ->
        e.preventDefault()
        if data.paginationInfo.currentPage != 1 then this.getPaginatedModels data, 1
    this.lastPage = (e, data) ->
        e.preventDefault()
        if data.paginationInfo.currentPage > 1 then this.getPaginatedModels data, data.paginationInfo.currentPage - 1
    this.nextPage = (e, data) ->
        e.preventDefault()
        if data.paginationInfo.currentPage < data.paginationInfo.totalPages then this.getPaginatedModels data, data.paginationInfo.currentPage + 1
    this.finalPage = (e, data) ->
        e.preventDefault()
        if data.paginationInfo.currentPage != data.paginationInfo.totalPages then this.getPaginatedModels data, data.paginationInfo.totalPages
    this.getPage = (e, pageIndex, data) ->
        e.preventDefault()
        if data.paginationInfo.currentPage != pageIndex then this.getPaginatedModels data, pageIndex
    this
]