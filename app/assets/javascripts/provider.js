// help dropdown

(function(){
  $(document).on('click', '#top-menu-help .toggle .open', function(event){
      $(this).closest("ul").addClass("expanded");
      event.stopPropagation();
    }).on('click', 'body', function(event){
      var menu = $("#top-menu-help");
      if(menu.find(event.target).length === 0 || $(event.target).is('a')) {
        menu.removeClass("expanded");
        event.stopPropagation();
      }
    });

  // general dropdown - TODO: merge with help dropdown
  $(document).on('click', '.dropdown-toggle', function(event){
    var dropdown = $(this).closest('a').siblings(".dropdown")

    dropdown.toggleClass('expanded');

    return false;
  });

  $(document).on('click', 'body', function(event){
    var expanded = $(".dropdown.expanded");
    if (expanded.length > 0) {
      expanded.removeClass("expanded");
      event.stopPropagation();
    }
  });

  $(document).on('submit', 'form', function(){
    var required = $(this).find(':input[required]');
    required = _(required).all(function(input) { return $(input).val() });

    if(!required) {
      $.flash('You have to fill all required inputs');
      return false;
    }
  });

}());
