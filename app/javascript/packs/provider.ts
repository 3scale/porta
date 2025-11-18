import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'
import 'Common/threescale'
import application from 'Common/application'
import 'Common/ajaxEvents'
import { setUpToasts } from 'utilities/toast'

const jQuery1 = window.$

document.addEventListener('DOMContentLoaded', () => {
  renderVerticalNav()
  renderQuickStarts()

  application()
  setUpToasts()

  /**
   * This is a legacy functionality that could be replaced with standard PF forms.
   */
  document.querySelectorAll<HTMLFormElement>('form.autosubmit')
    .forEach(form => {
      form.addEventListener('change', () => {
        if (form.dataset.remote) {
          void window.Rails.handleRemote.call(form, jQuery1(form))
        } else {
          form.submit()
        }
      })
    })
})
