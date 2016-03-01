 # Schedule.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
    autoCreatedAt: true
    autoUpdatedAt: true
    schema: true
    tableName: 'schedule'
    attributes:
        cityOfDeparture:
            type: 'string'
            required: true
        cityOfArrival:
            type: 'string'
            required: true
        startDate:
            type: 'datetime'
            required: true
        endDate:
            type: 'datetime'
            required: true
        username:
            type: 'string'
            required: true
            maxLength: 30
        comment:
            type: 'string'
            maxLength: 500
