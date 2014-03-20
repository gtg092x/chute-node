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

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

var Chute = function(config){
    this.options = _.merge({},(config&&config.options)?config.options:{},Chute.options);

    this.endpoint = 'https://api.getchute.com/v2';
    if(config){
        this.set(config);
    }

    var chute = this;


     /*
     =========Backbone Overrides=========
     */

    var defaults = {
        getClient:function(){
            return chute;
        },
        emulateHTTP : false,
        sync : function(mode,model,options) {

            options||(options={});
            options.type = options.type||(function(mode){
                switch(mode){
                    case "read":
                    default:
                        return "GET";
                    case "create":
                        return "POST";
                    case "update":
                        return "PUT";
                    case "delete":
                        return "DELETE";
                }
            }(mode));

            if (!options.url) {
                options.url = _.result(model, 'url') || urlError();
            }



            var req = {
                method: options.type.toLowerCase(),
                url: options.url,

                headers: {}
            };



            var client = this.getClient();
            if(client.token) {
                req.headers['Authorization'] = 'OAuth ' + client.token;
            }

            if(client.app_id){
                req.headers['x-client_id'] = client.app_id;
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
        }
    };

    var chuteModel = Backbone.Model.extend(defaults);



    /*
    =========Backbone Models=========
     */

    this.models = {};

    this.models.Album = chuteModel.extend({
            idAttribute: 'album',

            urlRoot: chute.endpoint + '/albums/',

            stats: function(options) {
                var self = this,
                    album = this.get('id') || this.get('album');

                request({
                    url: this.url() + '/stats',
                    method: 'get',
                    headers: {
                        'Authorization': 'OAuth ' + this.getClient().accessToken
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

    this.models.Asset = chuteModel.extend({
        idAttribute: 'asset',

        urlRoot: chute.endpoint + '/assets/'
    });


    /*
     =========Backbone Collections=========
     */

    this.collections={};

    var chuteCollection = Backbone.Collection.extend(defaults);

    this.collections.Albums= chuteCollection.extend({
            model: this.models.Album,

            url: chute.endpoint + '/albums/'
        });


    /*
     Syntatic Sugar for model access
     */
    _.each(this.collections,function(collection,key){

        chute[key.toLowerCase()] = {
            all:function(cb)
                {
                    var inst = new collection();

                    inst.fetch({success:function(result){
                        cb(null,result.toJSON());
                    },error:function(model,resp){
                        cb(resp);
                    }});

                    return inst;
                },

            find:function(data,cb){
                var col = new collection();

                var inst = new col.model(data);


                inst.fetch({success:function(result){
                    cb(null,result.toJSON());
                },error:function(model,resp){
                    cb(resp);
                }});

                return inst;
            }
        }
    });


};



Chute.setDefaults= function(options) {
    Chute.options = _.extend({}, Chute.options, options);
};

Chute.prototype.set = function(config){
    this.token = config.token;
    this.app_id = config.id;
};



module.exports = Chute;