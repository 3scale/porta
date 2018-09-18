;(function($){
  if(!$.browser.msie) { return; }

  if(typeof JSON!=='object') {
    $('head').append($('<script>', {src: '/javascripts/vendor/json2.min.js'}));
  }

  $(window).bind('load', function(){
    var version = parseInt($.browser.version, 10);

    $("[data-ie]").each(function(){
      var requires = parseInt($(this).data('ie'), 10);
      if(requires <= version) { return; }

      var element = $(this);
      var msg = "This feature requires Internet Explorer version " + requires + " or higher.\n" +
                "You can also use a different browser (Google Chrome, Mozilla Firefox and others).";
      var disable =  function(){ alert(msg); return false; };

      element.find(':input, button').attr('disabled', true);
      element.delegate('*', 'click', disable);
      element.delegate('form', 'submit', disable);
    });
  });

})(jQuery);
