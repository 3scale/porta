(function($) {
  $.flash = function(message) { $.flash.notice(message); };

  var timeouts = [],
      display_notice = function (message, clazz, opts) {
        if (message == '') {
          throw new Error('flash cannot be empty')
        }

    $.flash.current = message;

    html = '<div class="navbar navbar-fixed-top navbar-default alert alert-' + clazz + '" data-dismiss="alert">'
    html +=   '<div class="container">'
    html +=     '<button type="button" class="close" aria-hidden="true">×</button>'
    html +=      message
    html +=    '</div>'
    html +=  '</div>'
    $("#flash-messages").html(html);
  };

  $.flash.notice = function(message, opts) { display_notice(message, 'info', opts); };
  $.flash.error = function(message, opts)  { display_notice(message, 'error', opts); };

  $.flash.hide = function() {
    $.flash.current = null;
  };
})(jQuery);
