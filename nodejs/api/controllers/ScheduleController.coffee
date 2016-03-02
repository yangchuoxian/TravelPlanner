 # ScheduleController
 #
 # @description :: Server-side logic for managing schedules
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

Promise = require 'bluebird'
module.exports =
    ###
    Admin request to submit new schedule
    ###
    submitNewSchedule: (req, res) ->
        cityOfDeparture = req.param 'cityOfDeparture'
        cityOfArrival = req.param 'cityOfArrival'
        startDate = req.param 'startDate'
        endDate = req.param 'endDate'
        username = req.param 'username'
        comment = req.param 'comment'
        ### start input validation ###
        return res.send(400, sails.__ 'Please enter city of departure') if not cityOfDeparture
        return res.send(400, sails.__ 'Please enter city of arrival') if not cityOfArrival
        return res.send(400, sails.__ 'Please enter date of departure') if not startDate
        return res.send(400, sails.__ 'Please enter date of arrival') if not endDate
        return res.send(400, sails.__ 'Please provide username') if not username
        if comment
            return res.send(400, sails.__ 'Comment should not be longer than 500 characters') if comment.length > 500
        moment = require 'moment'
        startDate = new Date startDate
        endDate = new Date endDate
        momentOfStartDate = moment startDate
        momentOfEndDate = moment endDate
        now = moment()
        return res.send(400, sails.__ 'Invalid departure datetime') if momentOfStartDate.isBefore now
        return res.send(400, sails.__ 'Invalid arrival datetime') if momentOfEndDate.isBefore momentOfStartDate
        User.findOne username: username
        .then (foundUserWithUsername) ->
            return Promise.reject sails.__ 'User not found' if not foundUserWithUsername
            ### end input validation ###
            Schedule.create
                cityOfDeparture: cityOfDeparture
                cityOfArrival: cityOfArrival
                startDate: startDate
                endDate: endDate
                username: username
                comment: comment
        .then (createdSchedule) ->
            return Promise.reject sails.__ 'Server error' if not createdSchedule
            res.json createdSchedule
        .catch (err) -> res.send 400, err

    ###
    Mobile request to create new schedule
    ###
    createNewSchedule: (req, res) ->
        userId = req.param 'currentUserId'
        cityOfDeparture = req.param 'cityOfDeparture'
        cityOfArrival = req.param 'cityOfArrival'
        startDate = req.param 'startDate'
        endDate = req.param 'endDate'
        comment = req.param 'comment'
        ### start input validation ###
        return res.send(400, sails.__ 'Please enter city of departure') if not cityOfDeparture
        return res.send(400, sails.__ 'Please enter city of arrival') if not cityOfArrival
        return res.send(400, sails.__ 'Please enter date of departure') if not startDate
        return res.send(400, sails.__ 'Please enter date of arrival') if not endDate
        if comment
            return res.send(400, sails.__ 'Comment should not be longer than 500 characters') if comment.length > 500
        moment = require 'moment'
        startDate = new Date startDate
        endDate = new Date endDate
        momentOfStartDate = moment startDate
        momentOfEndDate = moment endDate
        now = moment()
        return res.send(400, sails.__ 'Invalid departure datetime') if momentOfStartDate.isBefore now
        return res.send(400, sails.__ 'Invalid arrival datetime') if momentOfEndDate.isBefore momentOfStartDate
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            ### end input validation ###
            Schedule.create
                cityOfDeparture: cityOfDeparture
                cityOfArrival: cityOfArrival
                startDate: startDate
                endDate: endDate
                username: foundUser.username
                comment: comment
        .then (createdSchedule) ->
            return Promise.reject sails.__ 'Server error' if not createdSchedule
            res.json createdSchedule
        .catch (err) -> res.send 400, err

    getSchedule: (req, res) ->
        scheduleId = req.param 'id'
        Schedule.findOne id: scheduleId
        .then (foundSchedule) ->
            return Promise.reject sails.__ 'Schedule not found' if not foundSchedule
            res.json foundSchedule
        .catch (err) -> res.send 400, err

    ###
    Admin requrest to delete schedule(s)
    ###
    deleteSchedule: (req, res) ->
        scheduleIds = req.param 'ids'
        Schedule.destroy().where id: scheduleIds
        .then -> res.send 'OK'
        .catch (err) -> res.send 400, err

    ###
    Mobile requrest to delet single schedule
    ###
    deleteUserSchedule: (req, res) ->
        scheduleId = req.param 'id'
        Schedule.destroy().where id: scheduleId
        .then -> res.send 'OK'
        .catch (err) -> res.send 400, err

    ###
    Mobile request to filter schedules within date range
    ###
    filterSchedules: (req, res) ->
        userId = req.param 'currentUserId'
        currentPage = req.param 'page'
        startTime = req.param 'startTime'
        endTime = req.param 'endTime'
        paginationCondition =
            page: currentPage
            limit: sails.config.constants.itemsPerPage
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            countCriteria =
                username: foundUser.username
                startDate:
                    '>': new Date startTime
                    '<': new Date endTime
            findCriteria = countCriteria
            findCriteria.sort = 'startDate asc'
            if currentPage      # Get paginated results
                Promise.resolve [
                    Schedule.count countCriteria
                    Schedule.find findCriteria
                    .paginate paginationCondition
                ]
                .spread (total, paginatedSchedules) ->
                    res.send 200,
                        paginationInfo: Toolbox.getPaginationInfo total, currentPage
                        models: paginatedSchedules
            else                # Get all results
                Schedule.find findCriteria
                .then (foundSchedules) ->
                    res.json models: foundSchedules
        .catch (err) -> res.send 400, err

    ###
    Mobile request to search schedules with given keyword
    ###
    searchSchedules: (req, res) ->
        keyword = req.param 'keyword'
        userId = req.param 'currentUserId'
        currentPage = req.param 'page'
        paginationCondition =
            page: currentPage
            limit: sails.config.constants.itemsPerPage
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            countCriteria =
                username: foundUser.username
                OR: [
                    {comment: {'contains': keyword}}
                    {cityOfDeparture: {'contains': keyword}}
                    {cityOfArrival: {'contains': keyword}}
                ]
            findCriteria = countCriteria
            findCriteria.sort = 'startDate asc'
            Promise.resolve [
                Schedule.count countCriteria
                Schedule.find findCriteria
                .paginate paginationCondition
            ]
        .spread (total, paginatedSchedules) ->
            res.send 200,
                paginationInfo: Toolbox.getPaginationInfo total, currentPage
                models: paginatedSchedules
        .catch (err) -> res.send 400, err


    getSchedulesWithCriteria: (req, res) ->
        keyword = req.param 'keyword'
        currentPage = req.param 'page'
        orderBy = req.param 'orderBy'
        order = req.param 'order'
        startTime = req.param 'startTime'
        endTime = req.param 'endTime'
        paginationCondition =
            page: currentPage
            limit: sails.config.constants.itemsPerPage
        countCriteria = findCriteria = {}
        if keyword
            countCriteria =
                OR: [
                    {comment: {'contains': keyword}}
                    {username: {'contains': keyword}}
                    {cityOfDeparture: {'contains': keyword}}
                    {cityOfArrival: {'contains': keyword}}
                ]
            findCriteria = countCriteria
        else if orderBy and order then findCriteria = sort: orderBy + ' ' + order
        else if startTime and endTime
            findCriteria =
                startDate:
                    '>': new Date startTime
                    '<': new Date endTime
                sort: 'time asc'
            countCriteria = findCriteria
        Promise.resolve [
            Schedule.count countCriteria
            Schedule.find findCriteria
            .paginate paginationCondition
        ]
        .spread (total, paginatedSchedules) ->
            res.send 200,
                paginationInfo: Toolbox.getPaginationInfo total, currentPage
                models: paginatedSchedules
        .catch (err) -> res.send 400, err

    ###
    For mobile user to change his/her own schedule
    ###
    changeSchedule: (req, res) ->
        scheduleId = req.param 'id'
        userId = req.param 'currentUserId'
        cityOfDeparture = req.param 'cityOfDeparture'
        cityOfArrival = req.param 'cityOfArrival'
        startDate = req.param 'startDate'
        endDate = req.param 'endDate'
        comment = req.param 'comment'

        ### Start input validation ###
        return res.send(400, sails.__ 'Please enter city of departure') if not cityOfDeparture
        return res.send(400, sails.__ 'Please enter city of arrival') if not cityOfArrival
        return res.send(400, sails.__ 'Please enter date of departure') if not startDate
        return res.send(400, sails.__ 'Please enter date of arrival') if not endDate
        if comment
            return res.send(400, sails.__ 'Comment should not be longer than 500 characters') if comment.length > 500
        moment = require 'moment'
        startDate = new Date startDate
        endDate = new Date endDate
        momentOfStartDate = moment startDate
        momentOfEndDate = moment endDate
        now = moment()
        return res.send(400, sails.__ 'Invalid departure datetime') if momentOfStartDate.isBefore now
        return res.send(400, sails.__ 'Invalid arrival datetime') if momentOfEndDate.isBefore momentOfStartDate
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            ### End of input validation ###
            Schedule.update id: scheduleId,
                cityOfDeparture: cityOfDeparture
                cityOfArrival: cityOfArrival
                startDate: startDate
                endDate: endDate
                comment: comment
        .then (updatedSchedules) ->
            return Promise.reject sails.__ 'Schedule not found' if not updatedSchedules
            res.send 'OK'
        .catch (err) -> res.send 400, err

    ###
    For admin to chnage all schedules
    ###
    updateBasicScheduleInfo: (req, res) ->
        scheduleId = req.param 'id'
        cityOfDeparture = req.param 'cityOfDeparture'
        cityOfArrival = req.param 'cityOfArrival'
        startDate = req.param 'startDate'
        endDate = req.param 'endDate'
        username = req.param 'username'
        comment = req.param 'comment'
        ### Start input validation ###
        return res.send(400, sails.__ 'Please enter city of departure') if not cityOfDeparture
        return res.send(400, sails.__ 'Please enter city of arrival') if not cityOfArrival
        return res.send(400, sails.__ 'Please enter date of departure') if not startDate
        return res.send(400, sails.__ 'Please enter date of arrival') if not endDate
        return res.send(400, sails.__ 'Please provide username') if not username
        if comment
            return res.send(400, sails.__ 'Comment should not be longer than 500 characters') if comment.length > 500
        moment = require 'moment'
        startDate = new Date startDate
        endDate = new Date endDate
        momentOfStartDate = moment startDate
        momentOfEndDate = moment endDate
        now = moment()
        return res.send(400, sails.__ 'Invalid departure datetime') if momentOfStartDate.isBefore now
        return res.send(400, sails.__ 'Invalid arrival datetime') if momentOfEndDate.isBefore momentOfStartDate
        User.findOne username: username
        .then (foundUserWithUsername) ->
            return Promise.reject sails.__ 'User not found' if not foundUserWithUsername
            ### End of input validation ###
            Schedule.update id: scheduleId,
                cityOfDeparture: cityOfDeparture
                cityOfArrival: cityOfArrival
                startDate: startDate
                endDate: endDate
                username: username
                comment: comment
        .then (updatedSchedules) ->
            return Promise.reject sails.__ 'Schedule not found' if not updatedSchedules
            res.send 'OK'
        .catch (err) -> res.send 400, err