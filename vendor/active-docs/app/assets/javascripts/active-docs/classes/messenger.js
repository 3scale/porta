(function(global, $){
  var data = false, Messenger = {}, Config = {}, currentTip;
  var desc = ThreeScale.APIDocs.tipDescriptions;
  var permitted_to_view = true;
  
  Config = {    
    origin: location.origin,

    data_url: {
      provider:"/p/admin/api_docs/account_data.json",
      buyer: "/api_docs/account_data.json"
    },
    
    support_host: "support.3scale.net",
    track_cookie: "3scale_domain",
    login_url:  "/api_docs/login"
  };
  
  
  function init(){
    if(onSupport()){
      checkReferrer();
      permitted_to_view = false;
      ThreeScale.APIDocs.permitted = false;
      $('.api-docs-wrap button').attr('disabled', 'disabled');
    } else {
      $.getJSON(Config.data_url[ThreeScale.APIDocs.account_type], handleData);
    }

    setEventHandlers();

    $('div.apidocs-signin-message a').click(function(){
      window.location = Config.login_url;
      return false;
    });
  }
  
  function setEventHandlers(){
    
    if(permitted_to_view){
      $(document).on('click', '.apidocs-param-tips li', copyValueToField);
      $(document).on('focus', 'input[type=text]', hideCurrentTip);
      $(document).on('focus', 'input[data-threescale-name]', showData);
    } 
    
    $(document).on('click', '.api-docs-wrap', function(e){
      if(!$(e.target).is("input,select")){
        hideCurrentTip();
      }
    });
  }
 
  function onSupport(){
    return window.location.host === Config.support_host;
  } 
  
  function checkReferrer(){
    var domain = $.cookie(Config.track_cookie), 
        pos,
        $box = $('.apidocs-param-tips.apidocs-nothere-message'),
        message = $box.html();

    if(domain && domain !== ''){
      message = message.replace('API Admin Portal', "<a href='http://"+domain+"/p/admin/api_docs'>API Admin Portal</a>");
      $box.html(message);
    }

    currentTip = $box;

    $(document).on('focus', '.api-docs-wrap input', function(){
      pos = getPosition($(this));
      $box.css({top:pos[1], left:pos[0]}).fadeIn('fast');
    });

  }
  
  function handleData(data){      
    Messenger.dataStatus = data.status;      
    if(data.status == '200'){
      for(var item in data.results){ 
        var values = {type: item, items:data.results[item]},
            tmpl = $.template(null, global.templates.paramTips);

        values.description = desc[item];
        $.tmpl(tmpl, values).appendTo($('.api-docs-wrap'));
      }
    }
  }
  
  function hideCurrentTip(){
    if(currentTip){
      currentTip.hide();
    }

    Messenger.currentField = null;    
  }
  
  function copyValueToField(e){
    if(Messenger.currentField){
      Messenger.currentField.val($(e.currentTarget).attr('data-value'));
      hideCurrentTip();
    }    
  }
  
  function showData(e){
    var $e = $(e.currentTarget), pos = getPosition($e),
    type = $e.attr('data-threescale-name');

    Messenger.currentField = $e;

    var $box = (Messenger.dataStatus == '401') ? $('.apidocs-param-tips.apidocs-signin-message') : $('.apidocs-param-tips.'+type);
    currentTip = $box;
    $box.css({top:pos[1], left:pos[0]}).fadeIn('fast');
    return false;
  }
  
  function getPosition($e){
    var pos = $e.position(),
    top = pos.top, 
    left = pos.left + $e.width() + 30;
    return [left, top];
  }
  

  global.Messenger = {
    init: init
  };
})(ThreeScale.APIDocs, ThreeScale.APIDocs.jQuery);
