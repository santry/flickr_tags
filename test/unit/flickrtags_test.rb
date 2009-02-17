require File.dirname(__FILE__) + '/../test_helper'

class FlickrTagsTest < Test::Unit::TestCase
  fixtures :pages
  test_helper :render 

  def setup
    @page = pages(:homepage)

    @request = ActionController::TestRequest.new :url => '/page/'
    @response = ActionController::TestResponse.new
  end

  def test_stupid
    assert_renders 'Homepage', "<r:title />"
  end
    
  def test_flickr_slideshow_parameters_are_required
    # assert_render_error %r{<iframe [^>]*.*>}, "<r:flickr:slideshow />"
    assert_render_error "Please provide a Flickr user name in the flickr:slideshow tag's `user` attribute", "<r:flickr:slideshow />"
    assert_render_error "Please provide a Flickr set ID in the flickr:slideshow tag's `set` attribute or a comma-separated list of Flickr tags in the `tags` attribute", "<r:flickr:slideshow user='foo' />"
  end  
  
  def test_flickr_slideshow_iframe
    needed_value="iframe .*user"
#    needed_value=FlickrTags::get_flickr_iframe('user','tags','foo,bar')
    assert_render_match needed_value, "<r:flickr:slideshow user='user' tags='foo,bar' />"

#    needed_value=FlickrTags::get_flickr_iframe('user','set_id','123456')
    assert_render_match needed_value, "<r:flickr:slideshow user='user' set='123456' />"
  end    
end
