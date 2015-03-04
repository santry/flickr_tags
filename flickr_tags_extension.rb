class FlickrTagsExtension < Radiant::Extension
  cattr_writer :cache_timeout
  def self.cache_timeout
    @@cache_timeout ||= SiteController.cache_timeout + 1.hour
  end

  version "0.3"
  description "Provides tags for embedding Flickr slideshows and photos"
  url "http://github.com/santry/flickr_tags"
  
  extension_config do |config|
    config.gem 'flickr_fu'
  end
  
  def activate
    Page.send :include, FlickrTags
  end
end