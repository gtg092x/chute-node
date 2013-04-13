var Chute = require('../'),
    Test = {
      asset: '',
      album: ''
    };

Chute.accessToken = process.env.TOKEN;

require('should');

describe('Chute', function(){
  describe('Album model', function(){
    it('should fetch an album', function(done){
      var album = new Chute.Album({ album: '9IZukfpi' });
      
      album.fetch({
        success: function(){
          album.attributes.should.have.property('id');
          done();
        }
      });
    });
    
    it('should return an error on non-existing album', function(done){
      var album = new Chute.Album({ album: 'joe' });
      
      album.fetch({
        error: function(model, err){
          err.code.should.equal(404);
          done();
        }
      });
    });
    
    it('should create a new album', function(done){
      var album = new Chute.Album({
        name: 'Test Album',
        moderate_comments: false,
        moderate_assets: false
      });
      
      album.save(null, {
        success: function(){
          album.attributes.should.have.property('id');
        
          Test.album = album.get('id');
        
          done();
        }
      });
    });
    
    it('should update an album', function(done){
      var album = new Chute.Album({ album: Test.album });
      
      album.fetch({
        success: function(){
          album.attributes.should.have.property('id');
          
          album.set('name', 'Updated test album');
          
          album.save(null, {
            success: function(){
              album.get('name').should.equal('Updated test album');
              done();
            }
          });
        }
      });
    });
    
    it('should get album\'s stats', function(done){
      var album = new Chute.Album({ album: Test.album });
      
      album.stats({
        success: function(model, stats){
          stats.should.have.property('user_counts');
          done();
        }
      });
    });
  });
});