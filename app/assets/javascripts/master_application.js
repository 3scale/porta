(function($) {

  $(document).ready(function() {
    (function(){

      if($('#template-pages').length == 0) return;
      // If a liquid page is being edited, then should be able to get the name of the section
      // page belongs to from location.hash.
      var section = location.hash.split('#')[1];
      $menuIndex = $("#template-index-menu");

      var currentPanel = (function(){
        return $(".liquid-index[data-section='"+section+"']");
      })();

      if(currentPanel.length > 0){
        currentPanel.show();
        $("#liquid-index-menu li a[data-section='"+section+"']").addClass('active');
      }
      else {
        $('.page-templates:first').show();
        $("li a:first", $menuIndex).addClass('active');
      }

      $("li a", $menuIndex).click(function(){
        $("li a",$menuIndex).removeClass('active');
        $('.page-templates').hide();
        $this = $(this);
        $this.addClass('active');
        var panel = $this.attr("data-section");
        $(".page-templates[data-section='"+panel+"']").show();
        return false;
      });
    })();

    $(document).on('click', '.metric_slot_close_button', function () {
      $('.metrics-subtable-toggle').removeClass('selected');
      $('.metric_slot, .plans_widget').remove();
      return false;
    });

    // Toggle visibility of DOM element.
    // Requires toggle switch to have class of 'toggle-pane',
    // and attribute 'data-pane' for ID of DOM element to toggle.
    // Can be persisted on server, by providing a URL as attribute 'data-url' on switch element.

    $('.toggle-pane').click(function(){
      var $this = $(this),
          value = 0,
          $pane = $("#" + $this.attr('data-pane')),
          url = $this.attr('data-url') || null;

      if($pane.is(':visible')){
        value = 1;
        this.innerHTML = 'show &raquo;';
        $pane.hide();
      } else {
        value = 0;
        this.innerHTML = 'hide &raquo;';
        $pane.show();
      }

      if(url){
        $.ajax({url:url, data:{value:value}, type:'PUT'});
      }

      return false;
    });

    (function(){
        var fieldPending = false;

        function respondToClick(event) {
            fieldPending = true;
        }

         $('iframe').mouseover(function(){
           respondToClick();
           return false;
         });
      })();

  }); // document ready

})(jQuery); // close anonymous function
