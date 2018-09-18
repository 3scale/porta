(function($) {
  $(document).ready(function() {
    $("form.autosubmit").on("change", function() {
      if($(this).data('remote') && typeof($.rails) != "undefined") {
        $.rails.handleRemote($(this));
      } else {
        this.submit();
      }
    });
  });
})(jQuery);
