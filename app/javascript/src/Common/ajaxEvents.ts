/**
 * Set up AJAX event listeners. Origin: app/assets/javascripts/ajax_events.js
 * Events are triggered by rails so we rely on jQuery 1 until we upgrade rails-jquery and plugins.
 */

const jQuery1 = window.$
const expected = '1.11.3'
const actual = jQuery1().jquery

if (actual !== expected) {
  throw new Error(`AJAX events declared in the wrong $. Expected: ${expected}, actual: ${actual}`)
}

const ajaxSpinnerId = 'ajax-in-progress'

jQuery1(document)
  .on('ajax:before', () => {
    $('body').append(`<div id="${ajaxSpinnerId}"><img src="/assets/ajax-loader.gif"></div>`)
  })
  .on('ajaxComplete ajax:complete', () => {
    $(`#${ajaxSpinnerId}`).remove()
  })
  .on('ajax:error', (_event, _xhr, status: string, error) => {
    alert(`Request failed - ${status}`)
    console.error(error)
  })
