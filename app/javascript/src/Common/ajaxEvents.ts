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
 * rails-ujs ajax events. List of events: app/javascript/src/Types/rails-ujs.d.ts
 */
$(document)
  .on('ajax:before', () => {
    window.ThreeScale.showSpinner()
  })
  .on('ajax:error', (event) => {
    const [response, status] = (event.originalEvent as AJAXErrorEvent<unknown>).detail
    console.error('ajax:error', response, status)
  })
  .on('ajax:complete', () => {
    window.ThreeScale.hideSpinner()
  })

/**
 * Handle errors in formtastic forms that are rendered inside a colorbox. The error template is
 * passed as responseText inside the XHR response.
 *
 * DEPRECATED: replace jquery/colorbox modals with Patternfly modals.
 * TODO: add a colorbox specific selector to separate this with non-legacy implementations.
 */
$(document).on('ajax:error', 'form[data-remote]:not(.pf-c-form)', (event) => {
  const [,, xhr] = (event.originalEvent as AJAXErrorEvent<Document>).detail

  // If EventTarget (modal's content) is replaced immediately, ajax:success and ajax:complete are not called and the spinner will stay
  setTimeout(() => {
    window.$.colorbox({ html: xhr.responseText })
  })
  event.stopPropagation()
})
