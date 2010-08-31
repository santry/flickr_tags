require 'flickr_fu'

module FlickrTags
  include Radiant::Taggable
  class TagError < StandardError;end
  
  def get_flickr_iframe(user, param_name, param_val)
<<EOS
  <iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=#{user}&#{param_name}=#{param_val}" 
    frameBorder="0" width="500" scrolling="no" height="500"></iframe>
EOS
  end

  
  tag "flickr" do |tag|
    tag.expand
  end
  
  tag "flickr:slideshow" do |tag|
    attr = tag.attr.symbolize_keys
    
    if (attr[:user])
      user = attr[:user].strip
    else
      raise TagError.new("Please provide a Flickr user name in the flickr:slideshow tag's `user` attribute")
    end
    
    if attr[:set]
      get_flickr_iframe user, 'set_id', attr[:set].strip
    elsif attr[:tags]
      get_flickr_iframe user, 'tags', attr[:tags].strip
    else
      raise TagError.new("Please provide a Flickr set ID in the flickr:slideshow tag's `set` attribute or a comma-separated list of Flickr tags in the `tags` attribute")
    end 
  end
  
  tag 'flickr:photos' do |tag|
    logger.info 'Flickr photos cache miss'
    
    attr = tag.attr.symbolize_keys
    
    options = {}
    
    [:limit, :offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d{1,4}$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute of `photos' tag must be a positive number between 1 and 4 digits")
        end
      end
    end
    
    assert_user_attribute tag
    
    key = ['photos', tag.attr['user'], options[:limit], options[:offset], tag.attr['tags']]
    tag.locals.flickr_photos = cached(key) do
      flickr.photos.search(
        :user_id => tag.attr['user'],
        'per_page' => options[:limit],
        'page' => options[:offset],
        'tags' => tag.attr['tags']
      )
    end
    
    result = ''
    
    tag.locals.flickr_photos.each do |photo|
      tag.locals.flickr_photo = photo
      result << tag.expand
    end
    
    result
  end
  
  desc %{
    Get a Flickr photo based on its Photo Id
    
    E.g. for the photo http://www.flickr.com/photos/ccgd/107274692/, the ID would be “107274692”
    
    *Usage*:

    <pre><code><r:photo id="107274692" /></code></pre>
  }
  tag 'flickr:photos:photo' do |tag|
    unless tag.attr['id']
      tag.expand
    else
      begin
        tag.locals.flickr_photo = flickr.photos.find_by_id tag.attr['id']
      end
    end
  end
  
  desc %{
    Prints the URL of the image file for the current photo
    
    set the size of the image via the +size+ attribute.
    Possible values are (depending on the photo)
    "Square", "Thumbnail", "Small", "Medium", "Medium 640", "Large" and "Original"
    
    +size+ defaults to 'Medium'
    
    *Usage*:

    <pre><code><r:photo:url [size="Original"] /></code></pre>
  }
  tag 'flickr:photos:photo:src' do |tag|
    select_size(tag).try :source
  end
  
  desc %{
    Prints the URL of the Flickr photo page
  }
  tag 'flickr:photos:photo:url' do |tag|
    tag.locals.flickr_photo.url_photopage
  end

  desc %{
    Prints the description of the current photo
  }
  tag 'flickr:photos:photo:description' do |tag|
    tag.locals.flickr_photo.try :description
  end
  
  desc %{
    Prints the title of the current photo
  }
  tag 'flickr:photos:photo:title' do |tag|
    tag.locals.flickr_photo.try :title
  end
  
  desc %{
    Prints an HTML <img> for the image
    
    set the size of the image via the +size+ attribute, allowed values are
    "Square", "Thumbnail", "Small", "Medium", "Medium 640", "Large" and "Original"
    
    +size+ defaults to 'Medium'
    
    *Usage*:

    <pre><code><r:image [size="Original"] /></code></pre>
  }
  tag 'flickr:photos:photo:image' do |tag|
    if image = select_size(tag)
      %Q{<img src="#{image.url}" width="#{image.width}" height="#{image.height}">}
    end
  end
  
  tag 'flickr:sets' do |tag|
    tag.expand
  end
  
  desc %{
    Prints its contents for each of the user's photosets
    
    Requires a flickr user id in the +user+ attribute
    
    *Usage*:
    
    <pre><code><r:flickr:sets:each user="asdasd@A32">…</r:flickr:sets:each></code></pre>
  }
  tag 'flickr:sets:each' do |tag|
    assert_user_attribute tag
    user_sets(tag.attr['user']).collect do |set|
      tag.locals.flickr_set = set
      tag.expand
    end.join
  end
  
  desc %{
    Selects one of the user's photosets by title
    
    Requires a flickr user id in the +user+ attribute
    When not inside a flickr:sets:each and there is no title attribute given, the title of the current page is used
    
    *Usage*:
    
    <pre><code><r:set user="asdasd@A32" [title="My holiday pictures"]>…</r:set></code></pre>
  }
  tag 'flickr:set' do |tag|
    # TODO: select set by flickr set id instead of user+title
    # flickr_fu doesn't seem to support this at the moment, there is no find_by_id method on the Flickr::Photosets class
    unless tag.locals.flickr_set
      assert_user_attribute tag
      title = tag.attr['title'] || tag.locals.page.title
      titled_set = user_sets(tag.attr['user']).detect {|s| s.title == title }
      tag.expand if tag.locals.flickr_set = titled_set
    else
      tag.expand
    end
  end
  
  desc %{
    Prints the title of the current set
  }
  tag 'flickr:set:title' do |tag|
    tag.locals.flickr_set.try :title
  end
  
  desc %{
    Prints the description of the current set
  }
  tag 'flickr:set:description' do |tag|
    tag.locals.flickr_set.try :description
  end
  
  tag 'flickr:set:photos' do |tag|
    tag.expand
  end
  
  desc %{
    Print the contents of this tag for each of the photos in the current photoset
  }
  tag 'flickr:set:photos:each' do |tag|
    tag.locals.flickr_set.get_photos.collect do |photo|
      tag.locals.flickr_photo = photo
      tag.expand
    end.join
  end
  
private
  def flickr
    @flickr ||= Flickr.new "#{RAILS_ROOT}/config/flickr.yml"
  end
  
  def cached(*args, &block)
    expiry = Time.zone.now + FlickrTagsExtension.cache_timeout
    key = (['flickr'] + args + [expiry.to_i]).flatten.join('-')
    Rails.cache.fetch(key, &block)
  end
  
  def user_sets(user_id)
    @user_sets ||= flickr.photosets.get_list :user_id => user_id
  end
  
  def select_size(tag)
    size = tag.attr['size'] || 'Medium'
    tag.locals.flickr_photo.sizes.detect { |i| i.label.downcase == size.downcase }
  end
  
  def assert_user_attribute(tag)
    raise TagError, "Tag #{tag.name} requires a Flickr user id in user attribute" unless tag.attr['user']
  end
end
