(function($) {
  $(document).ready(function() {
    var addAcceptHeader = function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript, text/html, application/xml, text/xml, */*");
    }

    function remote() {
      var form = $(this);
      var buttons = form.find("input[type=submit], button[type=submit]");

      $.ajax({
        type:       form.attr("method"),
        url:        form.attr("action"),
        data:       form.serializeArray(),
        beforeSend: addAcceptHeader,
        complete:   function() { buttons.removeAttr("disabled"); }
      });

      buttons.attr("disabled", "true");

      return false;
    };

    // Ajax forms
    $("form.remote").live("submit", remote);

    // Ajax links
    $("a.remote").live("click", function() {
      $.ajax({url: this.href, beforeSend: addAcceptHeader});
      return false;
    });

    // Ajax forms if rails.js is not loaded.
    if ($.rails === void 0) {
      $("form[data-remote]").live("submit", remote);
    }
  });
})(jQuery);
