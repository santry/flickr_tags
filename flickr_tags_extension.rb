require 'flickr_fu'

class FlickrTagsExtension < Radiant::Extension
  version "0.2"
  description "Provides tags for embedding Flickr slideshows and photos"
  url "http://github.com/santry/flickr_tags"
  
  def activate
    Page.send :include, FlickrTags
  end
end