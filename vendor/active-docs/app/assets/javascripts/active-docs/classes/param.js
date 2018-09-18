(function(global, $){

  function Param(param, operation, parent){
    if (!this.guid) this.guid = global.IDGenerator.guid();
    $.extend(this, param);
    this.operation = operation;
    this.parent = parent || false;
    this.count = 0;
    this.generateContainerName();

    // Cache Param object
    global.ParamStore.store(this);

    this.setDescription();
    return this;
  }

  function nameOfParent(_param){
    var name = '';
    (function(param){
      name += '_' + param.name;
      if(param.hasParent()){
        arguments.callee(param.parent);
      }
    })(_param);
    return name;
  }

  Param.prototype = {

    /**
     * Decides whether to present template with description inline or not.
     *
     */
    setDescription: function(){
      if(typeof(this.description_inline) != 'undefined' && this.description_inline){
        this.description_inline = this.description;
        delete this.description;
      } else {
        delete this.description_inline;
      }
    },

    /**
     * Constructs a `string` to be used as a CSS `class`
     * in the generated markup. The genereated string is stored as
     * `container_id`. Class must be unqie, to avoid clashing.
     *
     */
    generateContainerName: function(){
      var name = '', parent_name = '';

      if(this.hasParent()){
        name = this.parent.guid;
      } else {
        name = this.operation.resource.name +
          '_' + this.operation.guid +
          '_' + this.operation.httpMethod + '_params';
      }

      this.container_id = name;
    },

    arrayOrHash: function(){
      return this.dataType.search(/array|hash/) > -1;
    },

    toTemplate: function(){
      var that = this, tmpl, $container;

      tmpl = $.template(null, global.templates[this.templateName()]);
      if(this.hasParent()) $container = $('tbody[data-guid='+this.parent.guid+']');
      else $container = $('#' + this.container_id);

      $.tmpl(tmpl, this).appendTo($container);

      // Array param types contain nested params!
      if(this.dataType == 'array' || this.dataType == 'hash'){
        $.each(this.parameters, function(i, _param){
          param = new global.Param(_param, that.operation, that);
          param.toTemplate();
        });
      }
    },

    hasParent: function(){
      return this.parent ? true : false;
    },

    templateName: function(){
      var n = "paramTemplate";

      if (this.allowableValues && this.allowableValues.valueType == "LIST") {
        n += "Select";
      } else {

        if (this.readOnly){
          n += "ReadOnly";
        }

        if(this.paramType == 'body') {
          return "paramTemplateBody";
        }

        if (this.dataType == 'array' || this.dataType == 'hash') {
          n = "paramTemplateArray";
        }

        if (this.dataType == 'custom') {
          n = "paramTemplateCustom";
        }
      }

      return(n);
    }
  };

  global.Param = Param;
})(ThreeScale.APIDocs, ThreeScale.APIDocs.jQuery);
