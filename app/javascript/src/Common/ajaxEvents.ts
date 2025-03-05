/**
 * Set up AJAX event listeners. Origin: app/assets/javascripts/ajax_events.js
 * Events are triggered by rails so we rely on jQuery 1 until we upgrade rails-jquery and plugins.
 * Rails-UJS events: https://guides.rubyonrails.org/v6.1.0/working_with_javascript_in_rails.html#rails-ujs-event-handlers
 */

const jQuery1 = window.$

if (jQuery1.rails === undefined) {
  throw new Error('Rails UJS not loaded')
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
