;(function(){
  $(document)
    .on('ajax:before pjax:start', function(event, xhr, status){
      $('body').append('<div id="ajax-in-progress"><img src="/assets/ajax-loader.gif"></div>');
    })
    .on('ajaxComplete ajax:complete pjax:end', function(event, xhr, status){
      $('#ajax-in-progress').remove();
    })
    .on('ajax:error', function(event, xhr, status, error){
      alert('Request failed - ' + status);
      console.error(error);
      // report error to errorception in async manner
      setTimeout(function(){ throw(error) }, 1);
    });
}());
