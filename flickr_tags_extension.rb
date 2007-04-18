class FlickrTagsExtension < Radiant::Extension
  version "0.1"
  description "Provides tags for embedding Flickr slideshows"
  url "http://seansantry.com/svn/radiant/extensions/flickrtags/trunk/"
  
  def activate
    Page.send :include, FlickrTags
  end
end