module FlickrTags
  include Radiant::Taggable
  
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
      raise StandardError.new("Please provide a Flickr user name in the flickr:slideshow tag's `user` attribute")
    end
    
    if attr[:set]
      get_flickr_iframe user, 'set_id', attr[:set].strip
    elsif attr[:tags]
      get_flickr_iframe user, 'tags', attr[:tags].strip
    else
      raise StandardError.new("Please provide a Flickr set ID in the flickr:slideshow tag's `set` attribute or a comma-separated list of Flickr tags in the `tags` attribute")
    end 
  end

  tag 'flickr:photos' do |tag|
    
    cachekey = "flickrfotos-" + Date.today.to_s
    Rails.cache.fetch(cachekey) {
      logger.info "Flickr cache miss"
      


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

      raise StandardError.new("The `photos' tag requires a user id in `user' paramater") if tag.attr['user'].blank?

        flickr = Flickr.new "#{RAILS_ROOT}/config/flickr.yml"
        tag.locals.photos = flickr.photos.search(:user_id => tag.attr['user'], 'per_page' => options[:limit], 'page' => options[:offset])

        result = ''

        tag.locals.photos.each do |photo|
          tag.locals.photo = photo
          result << tag.expand
        end


        result
      }
    end

  tag 'flickr:photos:photo' do |tag|
    tag.expand
  end

  tag 'flickr:photos:photo:src' do |tag|
    tag.attr['size'] ||= 'Medium'
    tag.locals.photo.sizes.find{|p| p.label.downcase == tag.attr['size'].downcase}.source 
  end

  tag 'flickr:photos:photo:url' do |tag|
    tag.locals.photo.url_photopage
  end

  tag 'flickr:photos:photo:description' do |tag|
    tag.locals.photo.description
  end

  tag 'flickr:photos:photo:title' do |tag|
    tag.locals.photo.title
  end   
end
