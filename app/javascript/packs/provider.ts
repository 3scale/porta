import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'
import 'Common/threescale'
import application from 'Common/application'
import 'Common/ajaxEvents'
import { setUpToasts } from 'utilities/toast'

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
      form.addEventListener('change', e => {
        if (form.dataset.remote) {
          void window.Rails.handleRemote.call(form, e)
        } else {
          form.submit()
        }
      })
    })

  // Toggle target input disabled state via [data-toggle-target] checkboxes
  document.addEventListener('change', (event) => {
    const el = event.target as HTMLInputElement
    const targetId = el.getAttribute('data-toggle-target')
    if (targetId) {
      const target = document.getElementById(targetId) as HTMLInputElement | null
      if (target) target.disabled = !el.checked
    }
  })
})
