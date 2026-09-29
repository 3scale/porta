/**
 * Loaded by {% essential_assets %} for old dev portals that don't use 3scale.js or 3scale_v2.js.
 * For those portals, this is the only source of these features.
 */
(function($) {
  $(document).ready(function() {

    // disable links with 'data-disabled' attribute and display alert instead
    // delegation on body fires before rails.js
    $('body').delegate('a[data-disabled]', 'click', function(event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      alert($(this).data('disabled'));
      return false;
    });

    // For dev portals loaded via {% essential_assets %} without 3scale.js or 3scale_v2.js, this
    // file is the only source of colorbox integration.
    $(document).on('submit', 'form.colorbox[data-remote]', function (e) {
      $(this).on('ajax:complete', function(event, xhr, status){
        var form = $(this).closest('form');
        var width = form.data('width');
        $.colorbox({
          open: true,
          html: xhr.responseText,
          width: width,
          maxWidth: '85%',
          maxHeight: '90%'
        });
      })
    });

    $(document).on("click", "a.fancybox, a.colorbox", function (e) {
      $(this).colorbox({ open:true });
      e.preventDefault();
    });

    $(document).on('click', '.fancybox-close', function () {
      $.colorbox.close();
      return false;
    });

    // show errors from ajax in formtastic
    $(document).on('ajax:error', 'form:not(.pf-c-form)', function (event, xhr, status, error) {
      switch(status){
        case 'error':
          $.colorbox({html: xhr.responseText});
          event.stopPropagation()
          break;
      }
    });
  });

})(jQuery);
