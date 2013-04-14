var Backbone = require('backbone'),
    request = require('request'),
    async = require('async'),
    _ = require('lodash');

_.param = function(obj) {
  var qs = [];
  
  _.forIn(obj, function(value, key){
    qs.push(key + '=' + value);
  });
  
  return qs.join('&');
};

Backbone.emulateHTTP = false;

Backbone.ajax = function(options) {
  var req = {
    method: options.type.toLowerCase(),
    url: options.url,
    headers: {}
  };
  
  if(Chute.accessToken) {
    req.headers['Authorization'] = 'OAuth ' + Chute.accessToken;
  }
  
  if(options.contentType) {
    req.headers['Content-Type'] = options.contentType;
  }
  
  if(options.data) {
    if(req.method == 'put') {
      var data = JSON.parse(options.data);
      delete data.links;
      delete data.user;
      delete data.id;
      delete data.shortcut;
      delete data.created_at;
      delete data.updated_at;
      if(data.album) delete data.album;
      if(data.asset) delete data.asset;

      req.body = JSON.stringify(data); 
    } else {
      req.body = options.data;
    }
  }
  
  request(req, function(err, res, body){
    if(err) {
      if(options.error) options.error(err);
      return;
    }
    
    body = JSON.parse(body);
    
    if(_.contains(['get', 'put', 'delete'], req.method) && res.statusCode !== 200) {
      if(options.error) options.error(body.response);
      return;
    }
    
    if(req.method == 'post' && res.statusCode !== 201) {
      if(options.error) options.error(body.response);
      return;
    }
    
    options.success(body.data);
  });
};


var Chute = {
  endpoint: 'https://api.getchute.com/v2',
  
  accessToken: '',
  
  options: {},
  
  setDefaults: function(options) {
    this.options = _.extend({}, this.options, options);
  }
};


Chute.Album = Backbone.Model.extend({
  idAttribute: 'album',
  
  urlRoot: Chute.endpoint + '/albums/',
  
  stats: function(options) {
    var self = this,
        album = this.get('id') || this.get('album');
    
    request({
      url: this.url() + '/stats',
      method: 'get',
      headers: {
        'Authorization': 'OAuth ' + Chute.accessToken
      }
    }, function(err, res, body){
      if(err || res.statusCode != 200) {
        if(options.error) options.error(self, err || JSON.parse(body).response);
        return;
      }
      
      if(options.success) {
        options.success(self, JSON.parse(body).data);
      }
    });
  }
});

Chute.Albums = Backbone.Collection.extend({
  model: Chute.Album,
  
  url: Chute.endpoint + '/albums/'
});

module.exports = Chute;