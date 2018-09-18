(function(global, $){

  $(function(){
   $(document).on('click', '.api-docs-wrap li div.apidocs-heading', function(){
     var id = $(this).parent('li').attr('data-operation-id'),
         $content = $('div.content[data-operation-id='+id+']');

     if($content.is(':visible')){
       Docs.collapseOperation($content);
     } else {
       Docs.expandOperation($content);
     }
   });

   $(document).on('click', '.operation-heading a', function(){
     Docs.toggleEndpointListForResource($(this).attr('data-name'));
   });

   $(document).on('click', 'a.hide-response',function(){
    var $content = $('div.response[data-guid='+ $(this).attr('data-guid')+']');
    $content.slideUp();
    $(this).fadeOut();
    return false;
   });

});

  var Docs = {
    toggleEndpointListForResource: function(resource) {
      var elem = $('li#resource_' + resource + ' ul.endpoints');

      if (elem.is(':visible')) Docs.collapseEndpointListForResource(resource);
      else Docs.expandEndpointListForResource(resource);
    },

    // Expand resource
    expandEndpointListForResource: function(resource) {
      $('#resource_' + resource).addClass('active');

      var elem = $('li#resource_' + resource + ' ul.endpoints');
      elem.slideDown();
    },

    // Collapse resource and mark as explicitly closed
    collapseEndpointListForResource: function(resource) {
      $('#resource_' + resource).removeClass('active');

      var elem = $('li#resource_' + resource + ' ul.endpoints');
      elem.slideUp();
    },

    expandOperationsForResource: function(resource) {
      // Make sure the resource container is open..
      Docs.expandEndpointListForResource(resource);
      $('li#resource_' + resource + ' li.operation div.content').each(function() {
        Docs.expandOperation($(this));
      });
    },

    collapseOperationsForResource: function(resource) {
      // Make sure the resource container is open..
      Docs.expandEndpointListForResource(resource);
      $('li#resource_' + resource + ' li.operation div.content').each(function() {
        Docs.collapseOperation($(this));
      });
    },

    expandOperation: function(elem) {
      elem.slideDown();
    },

    collapseOperation: function(elem) {
      elem.slideUp();
    },

    toggleOperationContent: function(dom_id) {
      var elem = $('#' + dom_id);
      (elem.is(':visible')) ? Docs.collapseOperation(elem) : Docs.expandOperation(elem);
    }

  };
  global.Docs = Docs;

})(ThreeScale.APIDocs, ThreeScale.APIDocs.jQuery);
