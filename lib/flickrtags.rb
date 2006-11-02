require 'flickr'

def get_flickr_iframe(user = 'username', param_name, param_val)
<<EOS
  <iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=#{user}&#{param_name}=#{param_val}" 
    frameBorder="0" width="500" scrolling="no" height="500"></iframe>
EOS

end

Behavior::Base.define_tags do
  
  tag "flickr" do |tag|
    tag.expand
  end
  
  tag "flickr:slideshow" do |tag|
    tag.attr['user'] ||= 'username'
    
    if tag.attr['set']
      get_flickr_iframe tag.attr['user'], 'set_id', tag.attr['set']
    elsif tag.attr['tags']
      get_flickr_iframe tag.attr['user'], 'tags', tag.attr['tags']
    else
      raise TagError.new("We need to know what set or tags to use for the slideshow.")
    end 
  end

  tag 'flickr:user' do |tag|
    
    tag.expand
  end
  
  tag 'flickr:user:photos' do |tag|
    tag.expand
  end
  
  tag 'flickr:user:photos:each' do |tag|
    
    attr = tag.attr.symbolize_keys
    
    options = {}
    
    [:limit, :offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d{1,4}$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
        end
      end
    end    
    
    tag.attr['user'] ||= 'username'
    

    flickr = Flickr.new    
    user = flickr.users(tag.attr['user'])

    tag.locals.photos = user.photos(options[:limit], options[:offset])    

    result = ''

    tag.locals.photos.each do |photo|
      tag.locals.photo = photo
      result << tag.expand
    end

    result
    
  end
  
  tag 'flickr:user:photos:each:photo' do |tag|
    tag.expand
  end
  
  tag 'flickr:user:photos:each:photo:src' do |tag|
    tag.attr['size'] ||= 'Medium'    
    tag.locals.photo.source(tag.attr['size'])
  end
    
  tag 'flickr:user:photos:each:photo:description' do |tag|
    tag.locals.photo.description
  end
  
  tag 'flickr:user:photos:each:photo:title' do |tag|
    tag.locals.photo.title
  end  
 
 
  
  
  # Photoset tags
  
  tag "flickr:sets" do |tag|
     tag.expand
   end

   tag "flickr:sets:each" do |tag|

     tag.attr['user'] ||= 'username'

     flickr = Flickr.new    
     user = flickr.users(tag.attr['user'])

     tag.locals.sets = user.photosets    

     result = ''

     tag.locals.sets.each do |set|
       tag.locals.set = set
       result << tag.expand
     end

     result

  end
   
  tag "flickr:set" do |tag|
    tag.expand
  end
  
  tag "flickr:set:title" do |tag|
    tag.locals.set.title
  end
  
  tag 'flickr:set:link' do |tag|
    tag.locals.set.url.to_s
  end
  
  tag 'flickr:set:photos' do |tag|
    tag.expand
  end
  
  tag 'flickr:set:photos:each' do |tag|
    
  end
  
end
