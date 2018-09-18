// For parsing code blocks with highlighter.
hljs.initHighlightingOnLoad();

(function($) {
  // Object for holding various timers users in proceeding code.
  var timers = {
    checkDomain: 0
  };

  $(document).ready(function() {

     // *** Plan reordering ***

     // Check sortable method exists; only included in plans
     // index view.
     if(typeof $().sortable == 'function'){
       $("#plans-list ul").sortable({
         handle: "span.plan-drag",
         stop: function(event, ui) {
           var order = [];
           ui.item.parent().find('li').each(function(){
             order.push($(this).attr('data-plan-id'));
           });

          $.ajax({
            url: "/admin/plans/reorder.json",
            type: "POST",
            dataType: "json",
            data: $.param({positions:order}),
            success: function(data) {
              Messenger.notice("Plans successfully reordered.");
            }
          });
         }
       });
     }


     // Marking plan as default
     $('#plans-list input.master-select').change(function(){

       // get ID of plan selected/de-selected
       var value = this.value;
       var loading = true;

       // update plan in the db.
       $.ajax({
         complete: function(){
           loading = false;
         },

         url: "/admin/plans/"+value+"/update_master",
         type: "PUT",
         dataType: "script"
       });

       // uncheck ALL plans
       jQuery('input.master-select').attr('checked', false);

       // check selected plans
       jQuery(this).attr('checked', 'checked')
     });


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

    $('a.wiki_preview_trigger').click(function() {
      var params = $('form.wiki_page:first').serialize();
      params = params.replace('_method=put&','');
      $.fancybox.showActivity();
      $.ajax({
        type:     "POST",
        cache:    false,
        url:      this.href,
        data:     params,
        dataType: 'html',
        success:  function(data) {
        	$.fancybox(data);
          $("pre code").each(function(i,element) {
            window.hljs.highlightBlock(element, window.hljs.tabReplace);
          });
        }
      });
	    return false;
    });

    $('.metric_slot_close_button').live('click', function(){
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



    // 3scale front: 'Domain Name' suggestion functionality. Currently used on signup form, and generates
    // suggestion by pinging server with value for account organisation name


    // Admin: see admin/liquid_pages/(id)
    // Automatically jump to selected version.
    (function(){
      $('select#rollback-selectbox').change(function(){
        var vr  = this.options[this.selectedIndex].value,
           loc  = window.location.pathname + "?v=" + vr;

        location.href = loc;
      });
    })();



    // Admin
    // Behaviour stuff for plans management
    (function(){
      var $img = $('#infinity_image');
      $('input.watch_infinity').live('keypress', function(){
        this.value == '' ? $('#infinity_image').show() : $('#infinity_image').hide();
      });

      // $('form#new_pricing_rule').live('submit', function(){
      //   checkRule(this);
      // });

    })();

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
