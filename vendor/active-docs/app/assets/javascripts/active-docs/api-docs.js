if(typeof ThreeScale == 'undefined'){
  ThreeScale = {};
}

if(typeof location.origin == 'undefined'){
  var origin = location.protocol + "//" + location.host;

  if((location.protocol == "http" && location.port != 80) || (location.protocol == "https" && location.port != 443)) {
    origin += ":" + location.port;
  }

  location.origin = origin;
}

ThreeScale.APIDocs = {
  preview: false,
  // HACK: if the page is inside an iframe, location.origin is 'null'
  host: (location.origin == "null") ? '' : location.origin,
  account_type: "buyer",
  permitted: true,
  jQuery: window.jQuery.noConflict(true)
};

if(typeof $ == 'undefined'){
  window.$ = jQuery;
}

// Initialize function
ThreeScale.APIDocs.init = function(resources){

  // HACK: happens only if you are inside an iframe (have CMS toolbar
  // enabled) and you specify the host without protol.
  if (ThreeScale.APIDocs.host) {
    if (ThreeScale.APIDocs.host.indexOf('//') == 0 && location.protocol == 'about:') {
      ThreeScale.APIDocs.host = 'https:' + ThreeScale.APIDocs.host;
      console.warn("ActiveDocs: Changing 'host' to" + ThreeScale.APIDocs.host + " to avoid problems inside an iframe.");
    }
  }

  // Seed document with initial markup
  ThreeScale.APIDocs.jQuery('div.api-docs-wrap').html(ThreeScale.APIDocs.templates.backbone);

  new ThreeScale.APIDocs.ResourcesController().fetch(resources);
  ThreeScale.APIDocs.Messenger.init();
};
