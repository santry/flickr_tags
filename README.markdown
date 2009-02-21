FlickrTags
==========
FlickrTags is an extension for the [Radiant CMS][1] that provides tags for embedding [Flickr][2] slideshows and photographs in pages. You can see an example of an embedded slideshow at <http://seansantry.com/portfolio/>.

The latest version is available on [GitHub][4]. When cloning, ensure your clone is named `flickr_tags`:

    git clone git://github.com/santry/flickrtags.git vendor/extensions/flickr_tags

FlickrTags also depends on the `flickr_fu` gem, which in turn requires a [Flickr API key][5]. Once you've obtained your API key, put it in `config/flickr.yml` as follows:

    key: abc123abc123abc123abc123abc123abc123abc123
    secret: abc123abc123

Some of the tags require a `user` attribute, in which you must specify your Flickr user ID, not your Flickr screen name. If you don't know your Flickr user ID, you can look it up at <http://idgettr.com/>. 

`flickr:slideshow`
==================
The `flickr:slideshow` tag embeds a slideshow into a page (using an `iframe`). Photographs for the slideshow can be selected using a Flickr photoset ID or a comma-separated list of Flickr tags. For example, the tag

    <r:flickr:slideshow user="10622160@N00" tags="portfolio"/>
	
adds a slideshow of all photographs that the Flickr user with ID 10622160@N00 has tagged as `portfolio`. This creates an `iframe` like this in the page:

    <iframe align="center" src="http://www.flickr.com/slideShow/index.gne?user_id=10622160@N00&tags=portfolio" 
      frameBorder="0" width="500" scrolling="no" height="500"></iframe>

You can combine tags into a comma-separated list to get photos that match _all_ the tags in the list. This example would create a slideshow for all photos tagged as `portfolio` and `2005`:

    <r:flickr:slideshow user="10622160@N00" tags="portfolio,2005"/>
	
You can also create a slideshow from a photoset by replacing the `tags` attribute with the `set` attribute. First, get the set ID from the photoset URL. For example, if the photoset has the URL 

    http://www.flickr.com/photos/10622160@N00/sets/548374/

the set ID is `548374`. Then, specify the set ID in the `flickr:slideshow` tag

    <r:flickr:slideshow user="10622160@N00" set="548374"/>

`flickr:photos`
===============
The `flickr:photos` tag and its related tags embed individual photos. For example, 	

    <r:flickr:photos user="flickr-userid" limit="8" offset="1">
      <a href="<r:photo:url />"><img src="<r:photo:src size="square"/>" alt="<r:photo:title />" /></a>
    </r:flickr:photos>

The `flickr:photos` tag also takes an optional `tags` attribute with a comma-separated list of Flickr tags to search. Photos that match any of the given tags will be returned.

This addition was made by Bernard Grymonpon (http://www.openminds.be/)
	
Acknowledgments
===============
Thanks to [John Long][3] for creating Radiant and to [Flickr][2] for providing a great photo-sharing community.

[1]: http://radiantcms.org
[2]: http://flickr.com
[3]: http://wiseheartdesign.com/
[4]: http://github.com/santry/flickrtags/
[5]: http://www.flickr.com/services/api/misc.api_keys.html
