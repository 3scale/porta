(function(){
  $(document).on('click', 'form.formtastic fieldset[data-behavior~=toggle-inputs] legend', function(event){
    var legend = $(event.currentTarget);
    var fieldset = legend.closest('fieldset');
    var cookie_name = fieldset.data('cookie-name');
    var cookie_path = fieldset.data('cookie-path');

    fieldset.toggleClass('packed');
    fieldset.find('> ol').slideToggle(0.4, function(){
      var icon = legend.find('.fa');
      icon.toggleClass('fa-caret-right fa-caret-down');
      $.cookie( cookie_name, icon.hasClass('fa-caret-down'), {expires: 30, path: cookie_path});
    });
  });
}());


function toggledInputsInit() {
  $('form.formtastic fieldset[data-behavior~=toggle-inputs]').each(function(i,fieldset) {
    fieldset = $(fieldset);
    var cookie_name = fieldset.data('cookie-name');
    var cookie_path = fieldset.data('cookie-path');

    if (!JSON.parse($.cookie(cookie_name))) {
      fieldset.find('> ol').slideUp(0);
      fieldset.find('i').addClass('fa fa-caret-right');
      fieldset.addClass('packed');
    } else {
      fieldset.find('i').addClass('fa fa-caret-down');
      fieldset.removeClass('packed');
    }
  });
};
