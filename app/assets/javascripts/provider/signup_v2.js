//= require vendor/jquery-1.11.3.min.js

/**
 * How to use this library
 *
 * @example <caption>Create Signup Instance.</caption>
 * var signup = new ThreeScale.Signup({ fields: ["account[extra_fields][my_custom]"]});
 *
 * @example <caption>Render to a specific DOM element</caption>
 * signup.renderTo('#signup-modal .container');
 *
 * @example <caption>Hook callbacks on events</caption>
 * // Iframe document ready
 * signup.on('ready', function(event, form){ });
 *
 * // Iframe show
 * signup.on('show', function(event, form){ });
 *
 * // Iframe render
 * signup.on('render', function(event, form){ });
 *
 * @example <caption> Hook callbacks on signup response</caption>
 * // Signup response success
 * signup.on('success', function(response){ });
 *
 * // Signup response error
 * signup.on('error', function(response){ });
 **/

(function(){
    "use strict";

    if (typeof ThreeScale === 'undefined') {
        window.ThreeScale = {};
    }
    var ThreeScale = window.ThreeScale;

    var one = 1;

    /**
     * Initialize new Signup.
     *
     * @param {Object} [options]
     * @param {string} [options.server=https://master.example.com]
     * @param {string} [options.path=/p/signup]
     * @param {string[]} [options.fields=[]]
     * @constructor
     * @example
     * var signup = ThreeScale.Signup();
     * signup.render(selector);
     */
    var Signup = ThreeScale.Signup = function Signup(options) {
        Signup.$.extend(this, Signup.defaults, options);

        this.$ = Signup.$(this);
        this.$iframe = Signup.$("<iframe>", { css: { border: 'none', background: 'transparent', display: 'inline', height: 'auto' }});
        this._fetching = new Signup.$.Deferred();
        this._loading = new Signup.$.Deferred();
        this._loading.then(function() { this._fetch(); });

        this._iframeDomReadyListener();

        var iframe = this.$iframe[0];

        function resizeIframe(force) {
            var contents = iframe.contentDocument;

            if (contents) {
                var body = contents.documentElement;

                if (body) {
                    var expectedHeight = body.scrollHeight;
                    var currentHeight = iframe.scrollHeight;

                    if (force || (currentHeight !== expectedHeight && currentHeight !== expectedHeight + 10)) {
                        var style = iframe.style;
                        style.height = 'auto'; // reset the height, so content fills the needed space
                        style.height = body.scrollHeight + 10 + 'px';
                    }
                }
            }
        }

        this.on('ready', function(){
            resizeIframe(true);
        });

        (function resizeIframeLoop(){
            resizeIframe();
            window.requestAnimationFrame(resizeIframeLoop);
        }());
    };

    Signup.jQuery = Signup.$ = window.jQuery.noConflict(true);

    Signup.defaults = {
        server: "https://master.example.com",
        path:  "/p/signup",
        params: {},
        fields: [],
        form_selector: 'form.signup_form',
        origin: window.location.origin

    };
    Signup.readyEvent = 'DOMContentLoaded';

    /**
     * Posts {Signup.readyEvent} to parent document when DOM is loaded.
     * This is used in the signup, to notify the loading page.
     * @param {string} origin domain of the container document
     */
    Signup.loaded = function (origin) {
        if (!origin) { return; }

        Signup.$(document).ready(function postDomReady() {
            window.parent.postMessage(Signup.readyEvent, origin);
        });
    };

    var prototype = Signup.prototype;

    /**
     * Listen on events.
     *
     * @param {string} event
     * @param {function} callback
     */
    prototype.on = function (event, callback) {
        this.$.on(event, callback);
    };

    /**
     * Triggers an event.
     *
     * @param {string} event
     * @param {object} object
     */

    prototype.trigger = function(event, data) {
      this.$.triggerHandler(event, data);
    };

    /**
     * Renders the downloaded form to passed selector/element.
     * It waits until the form is loaded in the background.
     *
     * @param {string, HTMLElement} selector
     * @fires Signup#show
     */
    prototype.renderTo = function (selector) {
        var promise = this.load();

        this.selector = selector;

        var signup = this;
        var iframe = this.$iframe;

        promise.done(function iframeLoaded(data) {
            iframe.appendTo(selector);
            /**
             * @event Signup#show
             * @type {HTMLIFrameElement}
             */
            signup.$.triggerHandler('show', iframe);

            signup._renderIframe(data);

            if (one > 1) throw "can't render signup more than once";
            ++one;
        });
    };

    /**
     * Fire an AJAX call to load the form in the background.
     */
    prototype.load = function () {
        this._loading.resolveWith(this);
        return this._fetching.promise();
    };

    // Private API

    /**
     * Downloads the form from the server and resolves {_fetching} promise
     *
     * @private
     * @fires Signup#load
     */
    prototype._fetch = function() {
        var fetching = this._fetching;
        var signup = this;

        return this._ajax({
            data: { fields: this.fields },
            success: function loadSuccess(data) {
                /**
                 * @event Signup#load
                 * @type {string}
                 */
                signup.$.triggerHandler('load', data);
                fetching.resolve(data);
            },
            error: function loadError(data, xhr, status, error) {
                fetching.reject(xhr, status, error);
            }
        });
    };


    /**
     * Preconfigured AJAX call with cross domain and credentials setting.
     * @param params
     * @returns {$.Deferred}
     * @private
     */
    prototype._ajax = function (params) {
      var defaults = {
          url: this.server + this.path,
          xhrFields: {withCredentials: true},
          crossDomain: true, 
          data: Signup.$.extend({ signup_origin: this.signup_origin }, this.params),
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "3scale-Origin" : this.origin
          }
      };

      return Signup.$.ajax(Signup.$.extend(true, defaults, params));
    };

    /**
     * Adds listener for DOMReady event and triggers {{Signup._iframeReady}}.
     * @private
     */
    prototype._iframeDomReadyListener = function () {
        var signup = this;
        window.addEventListener("message", function dispatchMessageEvent(event) {
            switch (event.data) {
                case Signup.readyEvent:
                    signup._iframeReady();
                    break;
            }
        });
    };

    /**
     * Renders given HTML in its iframe.
     * @param {string} html
     * @fires Signup#render
     * @private
     */
    prototype._renderIframe = function (html) {
        var $iframe = this.$iframe;
        var iframe = $iframe[0];
        var signup = this;

        iframe.contentDocument.open();
        iframe.contentDocument.write(html);
        iframe.contentDocument.addEventListener('DOMContentLoaded', function(){
            signup.trigger('ready');
        });

        iframe.contentDocument.close();

        /**
         * @event Signup#render
         * @type {HTMLFormElement}
         */
        this.$.triggerHandler('render', iframe);
    };

    /**
     * Submit the form by AJAX.
     * @param {HTMLFormElement} form
     * @private
     */

    prototype._submitForm = function (form) {
        var signup = this;
        var fields = Signup.$.param({fields: signup.fields});

        var path = form.attributes.getNamedItem('action').value;

        this._ajax({
            url: this.server + path,
            type: "POST",
            data: [Signup.$(form).serialize(), fields].join('&'),
            success: function formSubmitted(response) {
                signup._handleFormResponse(response);
            }
        });
    };

    /**
     * Prepares the iframe after it is ready.
     * Hooks into form to submit it by ajax.
     *
     * @private
     * @fires Signup#ready
     */
    prototype._iframeReady = function () {
        var $document = this.$iframe.contents();
        var signup = this;

        $document.find(this.form_selector).on('submit',
            /**
             * @this {HTMLFormElement}
             * @param {jQuery.Event} event
             */
            function submitForm(event){
                if (!event.isDefaultPrevented()) {
                    event.preventDefault();

                    Signup.$(this).trigger(event);

                    signup._submitForm(this);
                }
            });

        /**
         * @event Signup#ready
         * @type {Document}
         */
        this.$.triggerHandler('ready', $document);
    };

    /**
     * Reloads the form or re renders it, depending if response was a redirect.
     * @param {XMLHttpRequest} response
     * @private
     * @fires Signup#success
     * @fires Signup#error
     */
    prototype._handleFormResponse = function (response) {
        /**
         * @event Signup#success
         * @type {XMLHttpRequest}
         */
        /**
         * @event Signup#error
         * @type {XMLHttpRequest}
         */
        this.$.triggerHandler(response.success ? 'success' : 'error', response);

        var signup = this;

        if (response.redirect) {
            this._ajax({ url: response.redirect }).then(function(response){
                signup._handleFormResponse(response);
            });
        } else {
            this._renderIframe(response);
        }
    };
}());
