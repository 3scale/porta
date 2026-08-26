/**
 * Spoiler alert: if you're reading this, it's already too late. jQuery 1 is loaded.
 *
 * Colorbox 1.6.4 is incompatible with jQuery 3 (uses .live, .bind, $.isFunction, $.support). It
 * must run on jQuery 1.12.4.
 *
 * This file loads jQuery 1.12.4 first, then colorbox (which attaches to it), then exports colorbox
 * to the global scope as window.colorbox. After this file, provider.js loads jquery3 which
 * overwrites the global $ and jQuery with jQuery 3.7.0.
 *
 * The loading order in provider.js is critical:
 *   1. vendor/colorbox
 *   2. jquery3
 *   3. rails-ujs
 *
 * All colorbox calls must use window.colorbox, not $.colorbox.
 *
 * jQuery.colorbox is both a callable function and an object with methods (.close, .resize).
 * .bind(jQuery) fixes the "this" context so colorbox works when called as window.colorbox().
 * Object.assign copies .close, .resize, etc. onto the bound function because .bind() creates
 * a bare function without the original's custom properties.
 */

//= require jquery
//= require vendor/jquery.colorbox-min.js

window.colorbox = Object.assign(jQuery.colorbox.bind(jQuery), jQuery.colorbox);
