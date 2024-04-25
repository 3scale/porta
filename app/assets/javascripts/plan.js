jQuery(function(){
  jQuery(document).on('mousedown', 'table#plans input[type=radio]', function () {
    jQuery('table#plans input[type=radio]:checked').removeAttr('checked');
  });
});
