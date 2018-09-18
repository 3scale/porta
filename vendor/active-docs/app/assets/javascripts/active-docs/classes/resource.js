(function(global, $){

  function Resource(config){
    // TODO: Extend `this` with config properties, instead of carrying around `config`
    this.config = config;
    this.path = config.path;
    this.config.friendly_name = config.name;
    this.name = config.system_name;
    this.config.name = this.name;
    this.domain = config.domain;
  }

  Resource.prototype = {
    toTemplate: function(){
      var tmpl = $.template(null, global.templates.resourceTemplate);
      $.tmpl(tmpl, this.config).appendTo($('#apidocs-resources'));

      tmpl = $.template(null, global.templates.apiTemplate);
      $.tmpl(tmpl, this.config).appendTo($('#'+this.config.name+'_endpoint_list'));

      this.getEndpoints();
    },

    // An Endpoint represents a resource and can have multiple opeations.
    // Each operation consists of an array of parameters.
    getEndpoints: function(){
      var url = global.host + this.path + '?' + +(new Date()), that = this;

      $.ajax(url, {
        dataType: (window.location.origin == global.host) ? 'json' : 'jsonp',
        success: function(endpoints){
          that.basePath = endpoints.basePath;
          $.each(endpoints.apis, function(i, endpoint){
            $.each(endpoint.operations, function(i, operation){
              // Instantiate an `Operation` for each endpoint specified in the JSON response.
              new global.Operation(operation, endpoint, that).toTemplate();
            });
          });

          // Subscribe to `resouces:loaded` with `$.subscribe('resources:loaded', callback)`
          $.publish('resources:loaded');
        }
      });
     }
  }

  global.Resource = Resource;
})(ThreeScale.APIDocs, ThreeScale.APIDocs.jQuery);
