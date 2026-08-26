(function(global, $){

  /**
   * Retreive the passed `apis`.
   *
   * @param {Object} options
   * @param {Object} endpoint - description of endpoint from spec
   * @param {Resource} resource
   *
   */

  Operation.template = Handlebars.compile(global.templates.operationTemplate);
  function Operation(options, endpoint, resource){
    if(!this.guid){
       this.guid = global.IDGenerator.guid();
    }

    $.extend(this, options);

    if(options.group){
      var groupIndex = Operation.groups.indexOf(options.group);

      if(groupIndex == -1){
        Operation.groups.push(options.group);
        groupIndex = Operation.groups.indexOf(options.group);
      }

      groupIndex = groupIndex % Operation.colours.length;
      this.groupColour = Operation.colours[groupIndex];
    }

    this.resource = resource;
    this.endpoint = endpoint;

    // Is the user permitted to query endpoints on this operation.
    // This should be a class variable - i.e. it should apply to all operations
    this.permitted = ThreeScale.APIDocs.permitted;

    this.httpMethodLowercase = this.httpMethod.toLowerCase();
    this.apiName = resource.name;
    this.path = endpoint.path;
    this.basePath = (function(){
      if(!resource.basePath || resource.basePath === '') return location.origin;
      else return resource.basePath;
    })();

    return this;
  }

  Operation.groups = [];
  Operation.colourThemes = {
    'island-sun': ['#F5E659', '#F6F896', '#B9B955', '#6D784A', '#EDCB42'],
    'african-sun': ['#F2E963', '#FDC55E', '#DA9A59', '#8C5637', '#40251B'],
    'light-of-the-day': ['#BABBAD', '#F7E3CA', '#C9A68F', '#DFE3D2', '#C5B898']
  }

  Operation.colours = Operation.colourThemes['light-of-the-day'];


  Operation.prototype = {

    toTemplate: function(){
      var that = this;
      $('#' + this.resource.config.name + '_endpoint_operations').append(Operation.template(this));

      $.each(this.parameters || [], function(i, param){
        new global.Param(param, that).toTemplate();
      });
    }

  };

  global.Operation = Operation;
})(ThreeScale.APIDocs, ThreeScale.APIDocs.jQuery);
