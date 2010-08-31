class FlickrTagsExtension < Radiant::Extension
  version "0.2"
  description "Provides tags for embedding Flickr slideshows and photos"
  url "http://github.com/santry/flickr_tags"
  
  extension_config do |config|
    config.gem 'flickr_fu'
  end
  
  def activate
    Page.send :include, FlickrTags
  end
end