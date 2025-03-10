import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'
import application from 'Common/application'
import 'Common/ajaxEvents'

const jQuery1 = window.$

window.ThreeScale = {}

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

  /**
   * HACK: Catch potential leftovers of switch.js. Idea is to load a not found page and hopefully
   * make some cucumbers fail.
   * /!\ Delete this before commiting to main.
   */
  $(document).on('submit', 'form.remote', () => {
    window.location.replace('/error-class-remote')
  })
  $(document).on('click', 'a.remote', () => {
    window.location.replace('/error-class-remote')
  })
})
