/**
 * Default model configuration
 * (sails.config.models)
 *
 * Unless you override them, the following properties will be included
 * in each of your models.
 *
 * For more info on Sails models, see:
 * http://sailsjs.org/#!/documentation/concepts/ORM
 */

module.exports.models = {

  /***************************************************************************
  *                                                                          *
  * Your app's default connection. i.e. the name of one of your app's        *
  * connections (see `config/connections.js`)                                *
  *                                                                          *
  ***************************************************************************/
  connection: 'someMongodbServer',

  /***************************************************************************
  *                                                                          *
  * How and whether Sails will attempt to automatically rebuild the          *
  * tables/collections/etc. in your schema.                                  *
  *                                                                          *
  * See http://sailsjs.org/#!/documentation/concepts/ORM/model-settings.html  *
  *                                                                          *
  ***************************************************************************/
  migrate: 'alter',


  /**
   * This method adds records to the database
   *
   * To use add a variable 'seedData' in your model and call the
   * method in the bootstrap.js file
   */
  seed: function() {
      var self = this;
      var modelName = self.adapter.identity.charAt(0).toUpperCase() + self.adapter.identity.slice(1);
      if (!self.seedData) {
          sails.log.debug('No data avaliable to seed ' + modelName);
          return Promise.resolve();
      }
      return self.count().then(function(count) {
          if (count === 0) {
              sails.log.debug('Seeding ' + modelName + '...');
              if (self.seedData instanceof Array) {
                  return self.seedArray();
              } else {
                  return self.seedObject();
              }
          } else {
              sails.log.debug(modelName + ' had models, so no seed needed');
              return Promise.resolve();
          }
      }).catch(function(err) {
          return Promise.reject(err);
      });
  },
  seedArray: function() {
      var self = this;
      var modelName = self.adapter.identity.charAt(0).toUpperCase() + self.adapter.identity.slice(1);
      return self.createEach(self.seedData).then(function(results) {
          sails.log.debug(modelName + ' seed planted');
          return Promise.resolve();
      }).catch(function(err) {
          sails.log.debug(err);
          return Promise.reject(err);
      });
  },
  seedObject: function() {
      var self = this; 
      var modelName = self.adapter.identity.charAt(0).toUpperCase() + self.adapter.identity.slice(1);
      return self.create(self.seedData).then(function(results) {
          sails.log.debug(modelName + ' seed planted');
      }).catch(function(err) {
          sails.log.debug(err);
          return Promise.reject(err);
      });
  }

};
