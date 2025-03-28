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

/**
 * rails-ujs ajax events.
 */
$(document)
  .on('ajax:before', (...args) => {
    console.log('ajax:before on', args)
    window.ThreeScale.showSpinner()
  })
  .on('ajax:beforeSend', (...args) => { console.log('ajax:beforeSend', args) })
  .on('ajax:send', (...args) => { console.log('ajax:send on', args) })
  .on('ajax:stopped', (...args) => { console.log('ajax:stopped', args) })
  .on('ajax:success', (...args) => { console.log('ajax:success', args) })
  .on('ajax:error', (event) => {
    const [response, status] = (event.originalEvent as AJAXErrorEvent<unknown>).detail
    console.error('ajax:error', response, status)
  })
  .on('ajax:complete', (...args) => {
    console.log('ajax:complete', args)
    window.ThreeScale.hideSpinner()
  })

/**
 * window.$.ajax events, triggered by Colorbox.
 */
window.$(document)
  .on('ajaxStart', (...args) => { console.log('ajaxStart', args) })
  .on('ajaxSend', (...args) => { console.log('ajaxSend', args) })
  .on('ajaxSuccess', (...args) => { console.log('ajaxSuccess', args) })
  .on('ajaxComplete', (...args) => { console.log('ajaxComplete', args) })
  .on('ajaxError', (...args) => { console.log('ajaxError', args) })

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
    window.$.colorbox({ html: xhr.responseText })
  })
  event.stopPropagation()
})
