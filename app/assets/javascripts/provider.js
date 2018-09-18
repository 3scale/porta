//= require provider/utils

/* Modernizr 2.6.2 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-input-inputtypes
 */
;window.Modernizr=function(a,b,c){function u(a){i.cssText=a}function v(a,b){return u(prefixes.join(a+";")+(b||""))}function w(a,b){return typeof a===b}function x(a,b){return!!~(""+a).indexOf(b)}function y(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:w(f,"function")?f.bind(d||b):f}return!1}function z(){e.input=function(c){for(var d=0,e=c.length;d<e;d++)o[c[d]]=c[d]in j;return o.list&&(o.list=!!b.createElement("datalist")&&!!a.HTMLDataListElement),o}("autocomplete autofocus list placeholder max min multiple pattern required step".split(" ")),e.inputtypes=function(a){for(var d=0,e,g,h,i=a.length;d<i;d++)j.setAttribute("type",g=a[d]),e=j.type!=="text",e&&(j.value=k,j.style.cssText="position:absolute;visibility:hidden;",/^range$/.test(g)&&j.style.WebkitAppearance!==c?(f.appendChild(j),h=b.defaultView,e=h.getComputedStyle&&h.getComputedStyle(j,null).WebkitAppearance!=="textfield"&&j.offsetHeight!==0,f.removeChild(j)):/^(search|tel)$/.test(g)||(/^(url|email)$/.test(g)?e=j.checkValidity&&j.checkValidity()===!1:e=j.value!=k)),n[a[d]]=!!e;return n}("search tel url email datetime date month week time datetime-local number range color".split(" "))}var d="2.6.2",e={},f=b.documentElement,g="modernizr",h=b.createElement(g),i=h.style,j=b.createElement("input"),k=":)",l={}.toString,m={},n={},o={},p=[],q=p.slice,r,s={}.hasOwnProperty,t;!w(s,"undefined")&&!w(s.call,"undefined")?t=function(a,b){return s.call(a,b)}:t=function(a,b){return b in a&&w(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(b){var c=this;if(typeof c!="function")throw new TypeError;var d=q.call(arguments,1),e=function(){if(this instanceof e){var a=function(){};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(q.call(arguments)));return Object(g)===g?g:f}return c.apply(b,d.concat(q.call(arguments)))};return e});for(var A in m)t(m,A)&&(r=A.toLowerCase(),e[r]=m[A](),p.push((e[r]?"":"no-")+r));return e.input||z(),e.addTest=function(a,b){if(typeof a=="object")for(var d in a)t(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,typeof enableClasses!="undefined"&&enableClasses&&(f.className+=" "+(b?"":"no-")+a),e[a]=b}return e},u(""),h=j=null,e._version=d,e}(this,this.document);

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

  // stub <input required>
  if(!Modernizr.input.required) {

    $(document).on('submit', 'form', function(){
      var required = $(this).find(':input[required]');
      required = _(required).all(function(input) { return $(input).val() });

      if(!required) {
        $.flash('You have to fill all required inputs');
        return false;
      }
    });

  }

}());
