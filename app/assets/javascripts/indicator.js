if(typeof Messenger == 'undefined'){
  var Indicator = {};
}

(function($){
  Indicator = {
    init: function(offsetX, offsetY) {
      var $body = $('body'),
          that  = this,
          oX = offsetX || 8,
          oY = offsetY || 5;
        
       $body.append('<div id="indicator" style="display:none; z-index: 1000; position:absolute; width:20px; height:20px; padding:6px; "><img src="/assets/spinner.gif" border="0"></div>');

       var  $indicator = $('#indicator');

       $body.mousemove(function(e){
          $indicator.css({top: e.pageY + oY + "px", left: e.pageX + oX + "px"});
        }); 

      $indicator.bind('complete', function(){
        $indicator.hide();
      }).bind('ajaxSend', function(){
        $indicator.show();
      });
    
    }
  };
})(jQuery);