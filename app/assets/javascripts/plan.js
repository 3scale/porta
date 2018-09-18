jQuery(function(){
  jQuery('table#plans input[type=radio]').live('mousedown', function(){
    jQuery('table#plans input[type=radio]:checked').removeAttr('checked');
  });
});