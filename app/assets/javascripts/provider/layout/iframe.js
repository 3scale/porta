//= require 'vendor/jquery-1.11.3.min.js'
//= require 'flash'
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
