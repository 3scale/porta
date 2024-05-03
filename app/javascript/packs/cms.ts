import jQueryUI from 'jquery'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/tabs'

// Export jQuery 3.7 with jquery-ui widgets to be used in:
// - app/assets/javascripts/provider/admin/cms/intro.js.coffee
// - app/assets/javascripts/provider/admin/cms/templates.js
// - app/assets/javascripts/provider/admin/cms/sidebar.js.coffee
window.jQueryUI = jQueryUI

const jQuery1 = window.$

/**
 * Called every time a CMS section is selected in the sidebar, including first render.
 */
jQuery1(document).on('cms-template:init', () => {
  advanceOptionsToggle()
})

/**
 * Pages in the CMS have an "Advanced options" fieldset that is toggleable. Its state is saved in a
 * cookie for future renders. This function:
 * - Reads that cookie and dynamically sets the initial state of the fields set (this is bad)
 * - Adds a click event handler to expand/collapse the fieldset and update the cookie (this is good)
 *
 * TODO: update ThreeScale::SemanticFormBuilder#toggled_inputs to include initial render, leave the
 * cookie handling to this script.
 */
function advanceOptionsToggle () {
  const fieldset = document.querySelector<HTMLFieldSetElement>('fieldset[data-behavior~=toggle-inputs]')

  if (!fieldset) {
    return
  }

  const { cookieName, cookiePath } = fieldset.dataset as { cookieName: string; cookiePath: string }

  /* eslint-disable @typescript-eslint/no-non-null-assertion -- It's all there */
  const icon = fieldset.querySelector('legend i')!
  const list = fieldset.querySelector('ol')!
  const cookie = jQuery1.cookie(cookieName)!
  const legend = fieldset.querySelector('legend')!
  /* eslint-enable @typescript-eslint/no-non-null-assertion */

  const isExpanded = JSON.parse(cookie) as boolean

  if (isExpanded) {
    icon.classList.add('fa', 'fa-caret-down')
    fieldset.classList.remove('packed')
  } else {
    list.classList.add('is-hidden')
    icon.classList.add('fa', 'fa-caret-right')
    fieldset.classList.add('packed')
  }

  legend.addEventListener('click', () => {
    fieldset.classList.toggle('packed')
    list.classList.toggle('is-hidden')
    icon.classList.toggle('fa-caret-right')
    icon.classList.toggle('fa-caret-down')

    const isNowExpanded = icon.classList.contains('fa-caret-down')
    jQuery1.cookie(cookieName, String(isNowExpanded), { expires: 30, path: cookiePath })
  })
}

/**
 * This is used by section_input. It sets the "partial path" input's placeholder according to the
 * selected section. When Path is focused and empty, it sets its value. This feature is weird and
 * ineffective unless the input is focused.
 *
 * If CMS is loaded for the first time whithin a section, the input won't exist so it has to wait
 * until DOMContentLoaded. On the other hand, if user is changing between sections the inputs are
 * already in the DOM so partialPaths can be called right away.
 *
 * TODO: encapsulate this better in inputs/section_input.rb
 */
window.ThreeScale.partialPaths = (paths) => {
  /* eslint-disable @typescript-eslint/no-non-null-assertion -- Presence was verified already */
  const path = document.querySelector<HTMLInputElement>('input.cms-path-autocomplete')!
  const section = document.querySelector<HTMLSelectElement>('select.cms-section-picker')!
  /* eslint-enable @typescript-eslint/no-non-null-assertion */

  function autocompletePath (select: HTMLSelectElement) {
    const currentSectionId = Number(select.value)
    path.setAttribute('placeholder', paths[currentSectionId])
  }

  section.addEventListener('change', (event) => {
    autocompletePath(event.target as HTMLSelectElement)
  })

  path.addEventListener('focus', () => {
    if (path.value === '') {
      path.value = path.getAttribute('placeholder') ?? ''
    }
  })

  autocompletePath(section) // Initial value, on render
}
