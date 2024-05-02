import jQueryUI from 'jquery'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/tabs'

// Export jQuery 3.7 with jquery-ui widgets to be used in:
// - app/assets/javascripts/provider/admin/cms/intro.js.coffee
// - app/assets/javascripts/provider/admin/cms/templates.js
// - app/assets/javascripts/provider/cms/sidebar.js.coffee
window.jQueryUI = jQueryUI

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
