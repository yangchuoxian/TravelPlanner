 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
    autoCreatedAt: true
    autoUpdatedAt: true
    schema: true
    tableName: 'user'
    attributes:
        username:
            type: 'string'
            required: true
            unique: true
            maxLength: 80
        email:
            type: 'string'
            required: true
            unique: true
            maxLength: 100
        password:
            type: 'string'
            required: true
            minLength: 6
        loginToken:
            type: 'string'
        role:
            model: 'role'
            required: true
        name:
            type: 'string'
            maxLength: 50
        phoneNumber:
            type: 'string'
            maxLength: 20
        citizenID:
            type: 'string'
            maxLength: 30
        avatar:
            type: 'string'