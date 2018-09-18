(function($) {
  // ever heard about a toggle() function of jQuery?
  $.fn.enableSwitch = function() {
    var context = this;

    context.find(".disabled_block").fadeOut(function() {
      context.find(".enabled_block").fadeIn();
    })
  }

  $.fn.disableSwitch = function() {
    var context = this;

    context.find(".enabled_block").fadeOut(function() {
      context.find(".disabled_block").fadeIn();
    })
  }
})(jQuery);
