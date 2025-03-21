/**
 * Set up AJAX event global listeners for Rails UJS (remote forms and links). They need to be
 * declared with jQuery so that they can be overridden by local listeners (e.stopPropagation).
 * Otherwise they will run after any other listeners, possibly breaking the UX.
 * Example:
 *   document.body.addEventListener('ajax:error', (event) => {
 *     // Do stuff to local component
 *
 *     // Prevent global listener to be called
 *     event.stopPropagation()
 *   })
 *
 * Origin: app/assets/javascripts/ajax_events.js
 */

import $ from 'jquery'

import type { AJAXErrorEvent } from 'Types/rails-ujs'

const ajaxSpinnerId = 'ajax-in-progress'

/**
 * rails-ujs ajax events. They can be handled with either jQuery, so let's use 3.x
 */
$(document)
  .on('ajax:before', (...args) => {
    console.log('ajax:before on ' + $().jquery, args)
    $('body').append(`<div id="${ajaxSpinnerId}"><img src="/assets/ajax-loader.gif"></div>`)
  })
  .on('ajax:beforeSend', () => { console.log('ajax:beforeSend on ' + $().jquery) })
  .on('ajax:send', () => { console.log('ajax:send on ' + $().jquery) })
  .on('ajax:stopped', () => { console.log('ajax:stopped on ' + $().jquery) })
  .on('ajax:success', (...args) => { console.log('ajax:success on ' + $().jquery, args) })
  .on('ajax:error', (event) => {
    const [response, status] = (event.originalEvent as AJAXErrorEvent<unknown>).detail
    console.error('ajax:error on ' + $().jquery, response, status)
  })
  .on('ajax:complete', (...args) => {
    console.log('ajax:complete on ' + $().jquery, args)
    document.getElementById(ajaxSpinnerId)?.remove()
  })

  .on('ajaxSuccess', (...args) => { console.log('ajaxSuccess on ' + $().jquery, args) })
  .on('ajaxComplete', (...args) => { console.log('ajaxComplete on ' + $().jquery, args) })
  .on('ajaxError', (...args) => { console.log('ajaxError on ' + $().jquery, args) })

/**
 * Colorbox modals loaded from a url will use window.$.ajax, that's why event listeners need to be
 * bound to window.$.
 */
const jQuery1 = window.$
jQuery1(document)
  .on('ajaxSuccess', (...args) => { console.log('ajaxSuccess on ' + jQuery1().jquery, args) })
  .on('ajaxComplete', (...args) => {
    console.log('ajaxComplete on ' + jQuery1().jquery, args)
    document.getElementById(ajaxSpinnerId)?.remove()
  })
  .on('ajaxError', (...args) => { console.log('ajaxError on ' + jQuery1().jquery, args) })

/**
 * Handle errors in formtastic forms rendered inside a colorbox. The error template is passed a
 * responseText inside the XHR response.
 *
 * DEPRECATED: replace jquery/colorbox modals with Patternfly modals.
 * TODO: add a colorbox specific selector to separate this with non-legacy implementations.
 */
$(document).on('ajax:error', 'form[data-remote]:not(.pf-c-form)', (event) => {
  const [,, xhr] = (event.originalEvent as AJAXErrorEvent<HTMLDocument>).detail

  // If EventTarget is replaceWith'ed immediately, ajax:success and ajax:complete are not called and the spinner will stay
  setTimeout(() => {
    jQuery1.colorbox({ html: xhr.responseText })
  })
  event.stopPropagation()
})

/**
 * ajaxSuccess, ajaxComplete and ajaxError (check this last one) are triggered from colorbox and
 * caught by window.jQuery only. And no rails-ujs events are triggered.
 */
