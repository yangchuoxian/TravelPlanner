 # Role.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
    autoCreatedAt: false
    autoUpdatedAt: false
    schema: true
    tableName: 'role'
    attributes:
        name:
            type: 'string'
            unique: true
            maxLength: 20
    seedData: [
        {name: 'user'}
        {name: 'admin'}
    ]
