

var Bubble = Class.create();
Bubble.prototype = {
  initialize: function(el) {
    this.offsetX = -8;
    this.offsetY = 38;

    this.target = el;
    // this.text = text;
    this.makeBubble();
  },
 
  makeBubble: function() {
    var bubble = $("bubble_" + this.target.title);
    // var bubble = new Element('div', { 'class': 'bubble'});
    // var content = new Element('div', { 'class': 'content'});
    // content.innerHTML = this.text;

    // bubble.appendChild(content);
    this.bubble = bubble;
    // new Insertion.Bottom(body, bubble);
    // bubble.hide();
    
    
    
    // set position

    // listen!
    
    this.target.observe('mouseover', (
        function() { 

          var position = this.target.cumulativeOffset();

          this.bubble.style.top = position[1] + this.offsetX + "px";
          this.bubble.style.left = position[0] + this.target.getWidth() + this.offsetY + "px";
          
          this.bubble.show(); 
        }).bind(this));
        
    this.target.observe('mouseout', (
        function() { 
          this.bubble.hide(); 
        }).bind(this));
        
  }
  
  
}

var BubbleHelper = {
  set: function(){
    $$('.define').each(function(l){
      new Bubble(l);      
    });
}}
  //     function(event) { 
  // 
  //       if ((event.element().className == 'submit' )) {
  // 
  //         var form = event.element().up('form');
  //         var formData = form.serialize(true);
  //         var url = form.action;
  //         
  //         this.ajaxPost(formData, url);
  //         event.stop();
  //       }
  //     })
  //   )        
  //   
  // }
