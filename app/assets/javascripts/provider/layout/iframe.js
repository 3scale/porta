//= require jquery
//= require rails-ujs
//= require_self



(function(){
    "use strict";

    window.gaReady = function gaReady (fn) {
        if (typeof(ga) === 'undefined' && typeof(analytics) === 'object') {
            analytics.ready(fn);
        } else {
            fn();
        }
    };
}());
