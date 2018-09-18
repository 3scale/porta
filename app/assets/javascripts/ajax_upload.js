// This jQuery plugin will turn form into ajax-multipart form (form capable of file
// uploads throught ajax). It is basically simplified version of this:  http://valums.com/ajax-upload/
(function($) {

  $.fn.ajaxUpload = function() {
    this.live("submit", function() {
      var form   = $(this);
      var iframe = createIFrame();

      form.attr("target", iframe.name);
    
      // HACK: force :format=js (Rails only!)
      form.attr("action", form.attr("action").replace(/(\.[^\.\/]+)?$/, '.js'));

	    var toDeleteFlag = false;	

      $(iframe).load(function() {
  	    if (iframe.src == "about:blank") {
  				// First time around, do not delete.
	  			if (toDeleteFlag) {
  	  			// Fix busy state in FF3
			  		setTimeout($(iframe).remove, 0);
				  }
  				return;
	  		}				
				
  			var doc = iframe.contentDocument ? iframe.contentDocument : frames[iframe.id].document;
        var response = doc.body.innerHTML;
        response = response.replace(/(^<[^>]+>)|(<\/[^>]+>$)/g, '')
                           .replace(/&lt;/g,'<')
                           .replace(/&gt;/g,'>')
                           .replace(/&amp;/g,'&'); 

        form.find("input[type=file]").val("");
        eval(response);
				
  			// Reload blank page, so that reloading main page
	  		// does not re-submit the post. Also, remember to
		  	// delete the frame
			  toDeleteFlag = true;				
  			iframe.src = "about:blank"; //load event fired
      });
    });
  };
  
  var createIFrame = function() {
		// unique name
		// We cannot use getTime, because it sometimes return
		// same value in safari :(
		var id = getUID();
		
		// Remove ie6 "This page contains both secure and nonsecure items" prompt 
		// http://tinyurl.com/77w9wh
    return $("<iframe>")
      .attr("src", "javascript:false;")
      .attr("name", id)
      .attr("id", id)
		  .hide()
      .appendTo($(document).find("body"))
      .get(0);
	}

  var getUID = function() {
    var id = 0;
    return function() {
      return 'ajax-upload-' + id++;
    };
  }(); 

})(jQuery);
