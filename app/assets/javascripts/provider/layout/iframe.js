//= require 'vendor/jquery-1.9.1.min.js'
//= require 'vendor/rails-1.0.3.js'
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
