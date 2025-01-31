import $ from 'jquery'

import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'
import application from 'Common/application'
import remote from 'Common/remote'

const jQuery1 = window.$

document.addEventListener('DOMContentLoaded', () => {
  renderVerticalNav()
  renderQuickStarts()

  application()
  remote()

  /**
   * This is a legacy functionality that could be replaced with standard PF forms.
   */
  document.querySelectorAll<HTMLFormElement>('form.autosubmit')
    .forEach(form => {
      form.addEventListener('change', () => {
        if (form.dataset.remote) {
          void jQuery1.rails.handleRemote(jQuery1(form))
        } else {
          form.submit()
        }
      })
    })

  /**
   * Set up ajax event listeners. Origin: app/assets/javascripts/ajax_events.js
   */
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
})
