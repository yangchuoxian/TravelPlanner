Promise = require 'bluebird'
module.exports =
    generateLoginToken: ->
        s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring 1
        s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

    ###
    Checks whether the request is from mobile by checking if the request url contains 'mobile/'
    @return boolean:    true if the request is from mobile, false if not
    ###
    isRequestFromMobileDevice: (reqURL) ->
        return true if reqURL.indexOf('mobile/') != -1
        return false

    ###
    Given a Date object, generate the yyyy-mm-dd string
    @param date:    the javascript Date object
    @return string: the date string such as '2015-10-18'
    ###
    getDateString: (date) ->
        yyyy = date.getFullYear().toString()
        mm = (date.getMonth() + 1).toString() # getMonth() is zero-based
        mm = '0' + mm if mm.length == 1
        dd = date.getDate().toString()
        dd = '0' + dd if dd.length == 1
        yyyy + '-' + mm + '-' + dd

    ###
    For a given Date object, generate the hour and minute string such as "18:30"
    @param date:    the Date object
    @return string: the hour:minute string
    ###
    getTimeString: (date) ->
        hh = date.getHours().toString()
        hh = '0' + hh if hh.length == 1         # pad with 0 if one digit
        mm = date.getMinutes().toString()
        mm = '0' + mm if mm.length == 1         # pad with 0 if one digit
        hh + ':' + mm

    ###
    file uploader Promisified version
    @param req: the http request
    @param uploadFolder: the destination folder to upload file to
    @param formName: the user defined form name from frontend
    ###
    uploadFile: (req, uploadFolder, formName) ->
        new Promise (resolve, reject) ->
            req.file(formName).upload
                maxBytes: 2000000
                dirname: uploadFolder
            , (err, files) ->
                if err then reject err
                else resolve files

    ###
    Resize image file to designated square size
    @param imageFilePath: the image file to resiz
    @param size: the designated size
    @param resizedImagePath: the resized image file save path
    ###
    resizeImage: (imageFilePath, size, resizedImagePath) ->
        im = require('gm').subClass imageMagick: true
        resizedHandle = im(imageFilePath).resize size, size
        resizedHandle.write = Promise.promisify resizedHandle.write
        resizedHandle.write resizedImagePath
        .catch (err) -> Promise.reject err

    ###
    Generate user seed data
    ###
    generateUserSeedingData: ->
        bcrypt = Promise.promisifyAll require 'bcrypt'
        seeds = []
        hashedPassword = ''
        bcrypt.genSaltAsync 10
        .then (salt) -> bcrypt.hashAsync '123456', salt
        .then (hash) ->
            hashedPassword = hash
            Promise.resolve [
                Role.findOne name: 'admin'
                Role.findOne name: 'user'
            ]
        .spread (foundAdminRole, foundUserRole) ->
            return Promise.reject sails.__ 'Role not found' if not foundAdminRole or not foundUserRole
            # Push the admin user first
            seeds.push
                email: 'admin@google.com'
                username: 'admin'
                role: foundAdminRole.id
                password: hashedPassword
            # Generate several dummy users
            for i in [1...80]
                seeds.push
                    email: 'ycx' + i + '@google.com'
                    username: 'ycx' + i
                    role: foundUserRole.id
                    password: hashedPassword
                    name: 'Chuoxian Yang' + i
            return seeds
        .catch (err) -> Promise.reject err

    ###
    Generate schedule seed data
    ###
    generateScheduleSeedingData: ->
        moment = require 'moment'
        seeds = []
        for i in [1...20]
            startMoment = moment()
            endMoment = moment()
            startMoment.subtract(i, 'days')
            endMoment.add(i, 'days')
            seeds.push
                cityOfDeparture: 'city' + i
                cityOfArrival: 'city' + (i + 1)
                username: 'ycx' + i
                startDate: startMoment.toDate()
                endDate: endMoment.toDate()
                comment: 'Test schedule for ' + i
        for i in [21...80]
            startMoment = moment()
            endMoment = moment()
            startMoment.subtract(i, 'days')
            endMoment.add(i, 'days')
            seeds.push
                cityOfDeparture: 'city' + i
                cityOfArrival: 'city' + (i + 1)
                username: 'ycx1'
                startDate: startMoment.toDate()
                endDate: endMoment.toDate()
                comment: 'Test schedule for ' + i
        seeds

    getPaginationInfo: (total, currentPage) ->
        total: total
        currentPage: currentPage
        itemsPerPage: sails.config.constants.itemsPerPage
