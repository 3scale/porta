;(function(){
  $(document)
    .on('ajax:before', function(event, xhr, status){
      $('body').append('<div id="ajax-in-progress"><img src="/assets/ajax-loader.gif"></div>');
    })
    .on('ajaxComplete ajax:complete', function(event, xhr, status){
      $('#ajax-in-progress').remove();
    })
    .on('ajax:error', function(event, xhr, status, error){
      alert('Request failed - ' + status);
      console.error(error);
    });
}());
