function visibility_condition_for(target_name, decider_name, value) {
  var target  = $('#' + target_name);
  var decider = $('#' + decider_name + '_input');

  decider.change(function(e) {
    if ($(this).val() == value) {
      target.show();
    } else {
      target.hide()
    }
  });

  decider.trigger('change');
}


