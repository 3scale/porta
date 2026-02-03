/**
 * TODO: delete this!!!
 *
 * All this was cleaned up and moved to Typescript in https://github.com/3scale/porta/pull/3754 but
 * it was good for the admin portal only. Unfortunately, some old dev portals will break because it
 * is still used by {% essential_assets %} and we must maintain this file here for backwards compatibility
 */
(function($) {
  $(document).on('click', '.show-trace-lr', function(e){
    e.preventDefault();
    // Show the next tr
    $(this).parents('tr').next().toggle();
    $(this).parents('tr').toggleClass('showing');
  });

  // rest
  $(document).ready(function() {

    // disable links with 'data-disabled' attribute and display alert instead
    // delegation on body fires before rails.js
    $('body').delegate('a[data-disabled]', 'click', function(event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      alert($(this).data('disabled'));
      return false;
    });

    (function(){
       // return if not in correct pages
      if($("#fields_definition_name").size() == 0 ) return;
       // define functions
	 function disableInterface(){
	   function enable_checkboxes(){
	     checkboxes_disabled(false);
	   }

	   function disable_checkboxes(){
	     checkboxes_disabled(true);
	   }
	   function checkboxes_disabled(action){
	     $("#fields_definition_hidden").attr('disabled',action);
	     $("#fields_definition_read_only").attr('disabled',action);
	     $("#fields_definition_required").attr('disabled',action);
	   }
	   function disable_name_field(){
	     $("#fields_definition_name")[0].value = $("#fields_definition_fieldname")[0].value;
	     $("#fields_definition_name").attr('readonly', true);
	   }
	   function clear_checkboxes(){
	     $("#fields_definition_hidden")[0].checked=false;
	     $("#fields_definition_read_only")[0].checked=false;
	     $("#fields_definition_required")[0].checked=false;
	   }

	   function clear_choices(){
	     $("#fields_definition_choices_for_views")[0].value = '';
	   }
	   function read_only_choices(action){
	     $("#fields_definition_choices_for_views").attr('readonly', action);
	   }
	   function enable_choices(){
	     read_only_choices(false);
	   }
	   function disable_choices(){
	     read_only_choices(true);
	   }

	   // new view
	   if($("#fields_definition_fieldname").size() != 0){
	     $("#fields_definition_fieldname").change(function() {
	       if($("#fields_definition_fieldname")[0].value == "[new field]"){
	         $("#fields_definition_name").attr('readonly', false);
	         $("#fields_definition_name")[0].value='';
	         clear_checkboxes();
	         enable_checkboxes();
	         clear_choices();
	         enable_choices();
	       }
	       else if($.inArray($("#fields_definition_fieldname")[0].value,
	      		$("#required_fields")[0].value.split(",")) != -1){
	       //non_modifiable fields
	         disable_name_field();
	         clear_checkboxes();
	         disable_checkboxes();
	         clear_choices();
		 enable_choices();
	       }
	       else {
	         disable_name_field();
	         clear_checkboxes();
	         enable_checkboxes();
	         clear_choices();
	         enable_choices();
	       }
	     });
	   }

           if (($("#fields_definition_required").size() != 0 ) &&
	       ($("#fields_definition_required")[0].checked)){
             $("#fields_definition_hidden")[0].checked=false;
             $("#fields_definition_read_only")[0].checked=false;
             $("#fields_definition_hidden").attr('disabled',true);
             $("#fields_definition_read_only").attr('disabled',true);
           }

	     //edit view
           if($("#fields-definitions-edit-view").size() != 0 ){
	     $("#fields_definition_name").attr('readonly', true);
	     $("#fields_definition_name").attr('disabled', true);
}	 };

	 disableInterface();
	 // disableCheckboxesOnload();
     })();

    (function(){
       // return if not in correct pages
       if($("#fields_definition_required").lenght==0) return;
       // define functions
       function synchronize_checkboxes(){
	 $("#fields_definition_required").change(function(){
	 if ($("#fields_definition_required")[0].checked){
	   $("#fields_definition_hidden")[0].checked=false;
	   $("#fields_definition_read_only")[0].checked=false;
	   $("#fields_definition_hidden").attr('disabled',true);
	   $("#fields_definition_read_only").attr('disabled',true);
	 }
	 else{
	   $("#fields_definition_hidden").attr('disabled',false);
	   $("#fields_definition_read_only").attr('disabled',false);
	 }});
       };
       // call function
       synchronize_checkboxes();
     })();

    // DEPRECATED: since the introduction of PF4 and React, colorbox is being removed.
    // Response of this form will be presented inside a colorbox.
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

    // Show panel on click.
    $("a.show-panel").click(function() {
      findPanel($(this)).fadeIn("fast");
      return false;
    })

    // Hide panel on click.
    $("a.hide-panel").click(function() {
      findPanel($(this)).fadeOut("fast");
      return false;
    })

    // Toggle panel on click.
    $("a.toggle-panel").click(function() {
      var panel = findPanel($(this));

      if (panel.is(":visible")) {
	panel.fadeOut("fast");
      } else {
	panel.fadeIn("fast");
      }

      return false;
    });

    var findPanel = function(link) {
      var id = link.attr("data-panel");

      if (id) {
	return $("#" + id);
      } else {
	return $(link.attr("href"));
      }
    }

    // DEPRECATED: since the introduction of PF4 and React, colorbox is being removed. Also jquery-ujs has been replaced with rails-ujs.
    // Added #colorbox selector to target only non-React forms
    // show errors from ajax in formtastic
    $(document).on('ajax:error', 'form:not(.pf-c-form)', function (event, xhr, status, error) {
      switch(status){
        case 'error':
          $.colorbox({html: xhr.responseText});
          event.stopPropagation()
          break;
      }
    });


    $(document).on('change', '#search_deleted_accounts', function () {
      $(this.form).submit();
    });
  });

})(jQuery);
