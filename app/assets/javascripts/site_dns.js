(function($){
  $(document).ready(function(){
    var form = $("#site_dns_fields");
    var fields = form.find("input[type=text]");
    var radios = form.find("input[type=radio]");
    var dedicated_value_changed = false;

    fields.focusout(function() {
      if ($(this).val() != '') {
        var that = this;

        $(this).closest('li').find('input[type=radio]').attr('checked', true);

        fields.each(function() {
          if (this != that) {
            $(this).val('');
          }
        });
      }
    });

    form.find("#account_domain_type_none").change(function() {
      if (this.checked) {
        fields.val('');
      }
    });

    $("#account_dedicated_domain").change( function(){
      dedicated_value_changed = true;
    });

    jQuery('form').submit(function(){
      var subdomain = jQuery('#account_dedicated_domain').val();
      var dedicated = jQuery('#account_domain_type_dedicated').attr('checked');
      if(dedicated && !subdomain.match(/^(\w*).3scale.net$/) && dedicated_value_changed){
        if(!confirm('Changing your domain out of *.3scale.net means that you already obtained the SSL certificates for your domain. If you do not have them or have questions about it open a Support Case at https://access.redhat.com/support/. Do you want to proceed? '))
          return false;
      }
      return;
    });
  });
})(jQuery);
