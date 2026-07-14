import $ from 'jquery'
import 'jquery-ui/ui/widgets/tabs'

document.addEventListener('DOMContentLoaded', () => {
  createGlower('#filter-glow', '#cms-filter input')
  createGlower('#type-glow', '#cms-sidebar-filter-type li')
  createGlower('#origin-glow', '#cms-sidebar-filter-origin li')
  createGlower('#partials-glow', '#cms-sidebar-filter-type li[data-filter-type="partial"]')
  createGlower('#layouts-glow', '#cms-sidebar-filter-type li[data-filter-type="layout"]')

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Imported on top
  $('#cms-intro-tabs').tabs!({
    classes: {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      'ui-tabs-active': 'pf-m-current'
    }
  })
})

/**
 * Highlights a collection of target elements when hovering the trigger element.
 *
 * @param triggerSelector Selector of the element that turns glow on
 * @param targetSelector Selector of the elements that will glow
 */
function createGlower (triggerSelector: string, targetSelector: string) {
  const trigger = document.querySelector(triggerSelector)
  const target = document.querySelectorAll(targetSelector)

  if (trigger === null) {
    return
  }

  trigger.addEventListener('mouseenter', () => {
    target.forEach(t => { t.classList.add('glowing') })
  })

  trigger.addEventListener('mouseleave', () => {
    target.forEach(t => { t.classList.remove('glowing') })
  })
}
