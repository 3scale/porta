(function(global){
  global.IDGenerator = {
    counter: 0,
    guid: function(){
      return this.counter++;
    }
  };

  global.ParamStore = {
    params: {},

    find: function(id){
     return this.params[id];
    },

    store: function(param){
      this.params[param.guid] = param;
      return true;
    } 
  };

})(ThreeScale.APIDocs);
