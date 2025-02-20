import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'
import application from 'Common/application'
import 'Common/ajaxEvents'

const jQuery1 = window.$

window.ThreeScale = {}
window.ThreeScale.CMS = {}

document.addEventListener('DOMContentLoaded', () => {
  renderVerticalNav()
  renderQuickStarts()

  application()

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
})
