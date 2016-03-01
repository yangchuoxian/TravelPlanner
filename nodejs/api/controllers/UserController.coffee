# UserController
#
# @description :: Server-side logic for managing users
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

Promise = require 'bluebird'
module.exports =
    ### User registration ###
    submitNewUser: (req, res) ->
        username = req.param 'username'
        password = req.param 'password'
        email = req.param 'email'
        userId = req.param 'id'
        userRoleId = ''
        bcrypt = Promise.promisifyAll require 'bcrypt'
        loginToken = Toolbox.generateLoginToken()
        createOrUpdateNewUser = ->
            Role.findOne name: 'user'
            .then (foundRole) ->
                return Promise.reject sails.__ 'User role not found' if not foundRole
                userRoleId = foundRole.id
                bcrypt.genSaltAsync 10
            .then (salt) -> bcrypt.hashAsync password, salt
            .then (hash) ->
                newUserJSON =
                    username: username
                    email: email
                    password: hash
                    role: userRoleId
                    loginToken: loginToken
                if userId   # database record is already created since user avatar uploaded first, now just update the existing record value
                    User.update {id: userId}, newUserJSON
                    .then (updatedUsers) ->
                        return Promise.reject sails.__ 'User not found' if not updatedUsers
                        updatedUsers[0]
                    .catch (err) -> Promise.reject err
                else
                    User.create newUserJSON
                    .then (createdUser) ->
                        return Promise.reject sails.__ 'Server error' if not createdUser
                        createdUser
                    .catch (err) -> Promise.reject err
            .catch (err) -> Promise.reject err
        ### start user input validation ###
        validator = require 'validator'
        return res.send(400, sails.__ 'Please enter username') if not username
        return res.send(400, sails.__ 'Please enter password') if not password
        return res.send(400, sails.__ 'Please enter email') if not email
        return res.send(400, sails.__ 'Please enter valid email') if not validator.isEmail email
        return res.send(400, sails.__ 'Password must be 6-20 character long') if password.length < 6 or password.length > 20
        User.findOne username: username
        .then (foundUserWithUsername) ->    # check if username is unique
            return Promise.reject sails.__ 'User with that username already exists' if foundUserWithUsername
            User.findOne email: email
        .then (foundUserWithEmail) ->       # check if email is unique
            return Promise.reject sails.__ 'User with that email already exists' if foundUserWithEmail
            ### end of user input validation ###
            createOrUpdateNewUser()
        .then (newUserObject) -> res.json newUserObject
        .catch (err) -> res.send 400, err

    ### User authentication ###
    submitLogin: (req, res) ->
        comparePassword = Promise.promisify require('bcrypt').compare
        username = req.param 'username'
        password = req.param 'password'
        userId = ''
        userObject = ''
        ### Validate username and password ###
        User.findOne username: username
        .then (foundUserWithUsername) ->
            return Promise.reject sails.__ 'User not found' if not foundUserWithUsername
            userId = foundUserWithUsername.id
            comparePassword password, foundUserWithUsername.password
        .then (match) ->
            return Promise.reject sails.__ 'Incorrect password' if not match
            loginToken = Toolbox.generateLoginToken()
            ### If the request is from admin panel, we need to remember the login status in session ###
            if not Toolbox.isRequestFromMobileDevice(req.url) then req.session.userId = userId
            User.update id: userId, {loginToken: loginToken}
        .then (updatedUsers) ->
            return Promise.reject sails.__ 'User not found' if not updatedUsers
            userObject = updatedUsers[0]
            Role.findOne name: 'admin'
        .then (adminRole) ->
            userObject.role = adminRole
            res.json userObject
        .catch (err) -> res.send 400, err

    logout: (req, res) ->
        userId = req.param 'id'
        req.session.userId = null
        User.update id: userId, {loginToken: ''}
        .then (updatedUsers) ->
            return Promise.reject sails.__ 'User not found' if not updatedUsers
            res.send 'logged out'
        .catch (err) -> res.send 400, err

    getAllUserRoles: (req, res) ->
        Role.find()
        .then (foundRoles) -> res.json 200, foundRoles
        .catch (err) -> res.send 400, err

    ###
    For mobile user to change his/her profile only
    ###
    updateUser: (req, res) ->
        userId = req.param 'id'
        username = req.param 'username'
        email = req.param 'email'
        name = req.param 'name'
        phoneNumber = req.param 'phoneNumber'
        citizenID = req.param 'citizenID'
        userObjectToUpdate = ''
        ### Start user input validation ###
        validator = require 'validator'
        return res.send(400, sails.__ 'Please enter valid email') if email and not validator.isEmail email
        return res.send(400, sails.__ 'Please enter valid mobile phone') if phoneNumber and not validator.isMobilePhone phoneNumber, 'en-US'
        return res.send(400, sails.__ 'Citizen ID too long') if citizenID and citizenID.length > 30
        return res.send(400, sails.__ 'Please provide user id') if not userId
        User.findOne id: userId
        .then (foundUserWithId) ->
            return Promise.reject sails.__ 'User not found' if not foundUserWithId
            userObjectToUpdate = foundUserWithId
            if username     # Check if the new username already exists for a different user
                User.findOne username: username
                .then (foundUserWithUsername) ->
                    return Promise.reject sails.__ 'User with that username already exists' if foundUserWithUsername and foundUserWithUsername.id isnt userId
                .catch (err) -> Promise.reject err
                ### End of user input validation ###
        .then ->
            User.update id: userId,
                email: email or userObjectToUpdate.email
                name: name or userObjectToUpdate.name
                citizenID: citizenID or userObjectToUpdate.citizenID
                phoneNumber: phoneNumber or userObjectToUpdate.phoneNumber
                username: username or userObjectToUpdate.username
        .then (updatedUsers) ->
            return Promise.reject sails.__ 'Server error' if not updatedUsers
            res.send 'OK'
        .catch (err) -> res.send 400, err

    ###
    For mobile user to change his/her password only
    ###
    changeUserPassword: (req, res) ->
        userId = req.param 'id'
        oldPassword = req.param 'oldPassword'
        newPassword = req.param 'newPassword'
        confirmPassword = req.param 'confirmPassword'
        bcrypt = Promise.promisifyAll require 'bcrypt'
        ### Start validation ###
        return res.send(400, sails.__ 'Please enter all require filed') if not oldPassword or not newPassword or not confirmPassword
        return res.send(400, sails.__ 'Password mismatch') if newPassword isnt confirmPassword
        return res.send(400, sails.__ 'Password must be 6-20 character long') if newPassword.length < 6 or newPassword.length > 20
        User.findOne id: userId
        .then (foundUserWithId) ->
            return Promise.reject sails.__ 'User not found' if not foundUserWithId
            bcrypt.compareAsync oldPassword, foundUserWithId.password
        .then (match) -> Promise.reject sails.__ 'Incorrect password' if not match
        .then -> bcrypt.genSaltAsync 10
        .then (salt) -> bcrypt.hashAsync newPassword, salt
        .then (hash) ->
            User.update id: userId,
                password: hash
        .then -> res.send 'OK'
        .catch (err) -> res.send 400, err

    ###
    For admin to change all user info
    ###
    updateBasicUserInfo: (req, res) ->
        userInfo = req.param 'user'
        password = req.param 'password'
        bcrypt = Promise.promisifyAll require 'bcrypt'
        ### Start user input validation ###
        validator = require 'validator'
        return res.send(400, sails.__ 'Please enter valid email') if userInfo.email and not validator.isEmail userInfo.email
        return res.send(400, sails.__ 'Please enter valid mobile phone') if userInfo.phone and not validator.isMobilePhone userInfo.phone, 'en-US'
        return res.send(400, sails.__ 'Citizen ID too long') if userInfo.citizenid and userInfo.citizenid.length > 30
        return res.send(400, sails.__ 'Please provide user id') if not userInfo.id
        userObjectToUpdate = ''
        User.findOne id: userInfo.id
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            userObjectToUpdate = foundUser
            User.update id: userInfo.id,
                email: userInfo.email or userObjectToUpdate.email
                name: userInfo.name or userObjectToUpdate.name
                citizenID: userInfo.citizenID or userObjectToUpdate.citizenID
                phoneNumber: userInfo.phoneNumber or userObjectToUpdate.phoneNumber
                username: userInfo.username or userObjectToUpdate.username
                role: userInfo.role.id
        .then (updatedUsers) ->
            if password
                return res.send(400, sails.__ 'Password must be 6-20 character long') if password.length < 6 or password.length > 20
                bcrypt.genSaltAsync 10
                .then (salt) -> bcrypt.hashAsync password, salt
                .then (hash) ->
                    User.update id: userInfo.id,
                        password: hash
                .catch (err) -> Promise.reject err
        .then -> res.send 'OK'
        .catch (err) -> res.send 400, err


    deleteUser: (req, res) ->
        userIds = req.param 'ids'
        Schedule.destroy().where user: userIds
        .then -> User.destroy().where id: userIds
        .then -> res.send 'OK'
        .catch (err) -> res.send 400, err

    updateUserRole: (req, res) ->
        userIds = req.param 'ids'
        newRoleId = req.param 'roleId'
        roleObject = ''
        Role.findOne id: newRoleId
        .then (foundRoleWithId) ->
            return Promise.reject sails.__ 'Role not found' if not foundRoleWithId
            roleObject = foundRoleWithId
            User.update id: userIds,
                role: newRoleId
        .then (updatedUsers) ->
            return Promise.reject sails.__ 'User not found' if not updatedUsers
            res.send 200, roleObject
        .catch (err) -> res.send 400, err

    uploadUserAvatar: (req, res) ->
        userId = req.param 'modelId'
        userId = userId.trim() if userId
        mkdirp = Promise.promisify require 'mkdirp'
        uploadFolder = sails.config.constants.uploadFolderPath + '/' + Toolbox.getDateString(new Date()) + '/'
        uploadedFileUrl = ''
        mkdirp uploadFolder
        .then -> Toolbox.uploadFile req, uploadFolder, 'avatar'
        .then (files) ->
            uploadedFileUrl = files[0].fd.substring sails.config.constants.uploadFolderPath.length
            Toolbox.resizeImage files[0].fd, sails.config.constants.avatarImageSize, files[0].fd
            .then ->
                # If the image file does NOT have an extension, add a .jpg as its extension
                path = require 'path'
                fs = require 'fs'
                fs.rename = Promise.promisify fs.rename
                if not path.extname files[0].fd
                    uploadedFileUrl = uploadedFileUrl + '.jpg'
                    fs.rename files[0].fd, files[0].fd + '.jpg'
            .then ->
                # Upload avatar for an existing user
                if userId
                    User.update id: userId,
                        avatar: uploadedFileUrl
                else    # Upload avatar for a new user
                    Role.findOne name: 'user'
                    .then (foundRole) ->
                        return Promise.reject sails.__ 'Role not found' if not foundRole
                        User.create
                            # Dummy user data, only avatar and role id is real
                            email: uploadedFileUrl + '@email.com',
                            username: uploadedFileUrl
                            password: '123456'
                            role: foundRole.id
                            avatar: uploadedFileUrl
                        .then (createdUser) ->
                            return Promise.reject sails.__ 'Server error' if not createdUser
                            # After new user is created, the user has an id now
                            userId = createdUser.id
                        .catch (err) -> Promise.reject err
            .then ->
                res.json
                    avatarUrl: sails.config.constants.userAvatarBaseUrl + userId
                    modelId: userId
            .catch (err) -> res.send 400, err

    getUserAvatar: (req, res) ->
        userId = req.param 'id'
        userId = req.session.userId if not userId
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__('User not found') if not foundUser
            if foundUser.avatar then res.sendfile sails.config.constants.uploadFolderPath + foundUser.avatar
            else res.sendfile sails.config.constants.defaultAvatarUrl
        .catch (err) -> res.send 400, err

    getUserInfo: (req, res) ->
        userId = req.param 'id'
        userId = req.param 'currentUserId' if not userId
        userId = req.session.userId if not userId
        userObject = ''
        User.findOne id: userId
        .then (foundUser) ->
            return Promise.reject sails.__ 'User not found' if not foundUser
            # Remove user credentials before sending the user info back
            foundUser.password = ''
            foundUser.loginToken = ''
            userObject = foundUser
            Role.findOne id: userObject.role
            userObject.avatar = sails.config.constants.userAvatarBaseUrl + userObject.id
        .then (foundRole) ->
            userObject.role = foundRole
            res.json userObject
        .catch (err) -> res.send 400, err

    getUsersWithCriteria: (req, res) ->
        keyword = req.param 'keyword'
        currentPage = req.param 'page'
        orderBy = req.param 'orderBy'
        order = req.param 'order'
        role = req.param 'role'
        paginatedUsers = []
        paginationCondition =
            page: currentPage,
            limit: sails.config.constants.itemsPerPage
        countCriteria = findCriteria = {}
        if currentPage  # Get pagination results and pagination info
            if keyword  # Search users
                countCriteria =
                    OR: [
                        {username: {'contains': keyword}}
                        {name: {'contains': keyword}}
                    ]
                findCriteria = countCriteria
            else if orderBy and order then findCriteria = sort: orderBy + ' ' + order   # order users list
            else if role
                countCriteria = role: role
                findCriteria = role: role
            Promise.resolve [
                User.count countCriteria
                User.find findCriteria
                .paginate paginationCondition
            ]
            .spread (total, paginatedUsers) ->
                Promise.each paginatedUsers, (user) ->
                    Role.findOne id: user.role
                    .then (foundRole) -> user.role = foundRole
                    .catch (err) -> Promise.reject err
                .then ->
                    res.send 200,
                        paginationInfo: Toolbox.getPaginationInfo total, currentPage
                        models: paginatedUsers
            .catch (err) -> res.send 400, err
        else            # Get all results, no pagination
            if keyword  # Search users
                User.find
                    OR: [
                        {username: {'constains': keyword}}
                        {name: {'contains': keyword}}
                    ]
                .then (foundUsers) ->
                    Promise.each foundUsers, (user) ->
                        Role.findOne id: user.role
                        .then (foundRole) -> user.role = foundRole
                        .catch (err) -> Promise.reject err
                    .then -> res.send 200, foundUsers
                .catch (err) -> res.send 400, err
