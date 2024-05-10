import $ from 'jquery'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/tabs'

import * as flash from 'utilities/flash'

import type { EditorFromTextArea } from 'codemirror'

const jQuery1 = window.$

/**
 * Called every time a CMS section is selected in the sidebar, including first render.
 */
jQuery1(document).on('cms-template:init', () => {
  advanceOptionsToggle()
  buildSaveDropdownButton()
  setUpSectionDrop()
  setUpEditorTabs()

  jQuery1('#cms_template_content_type, #cms_template_liquid_enabled').trigger('change')
})

jQuery1(document).on('cms-sidebar:update', () => {
  setUpSidebarDrag()
})

document.addEventListener('DOMContentLoaded', () => {
  setUpContentTypeLiquidEnabledListener()
  setUpRevertButton()
  setUpRemoveFromSectionAction()

  jQuery1('#tab-content').trigger('cms-template:init')
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

/**
 * Build "Save" dropdown button. FIXME: Why is this is done dynamically remains a mystery 🤦‍♂️
 */
function buildSaveDropdownButton () {
  const $toggle = $('<a class="important-button dropdown-toggle" href="#">').append('<i class="fa fa-caret-down">')

  document.querySelectorAll('.dropdown-buttons ol')
    .forEach(el => {
      let $list = $(el)
      $list.find('li:first :input')
        .clone()
        .insertBefore($list)
        .addClass('important-button')

      // Replace ol with ul because of formtastic
      $list.replaceWith(() => {
        const content = jQuery1(el).html()
        $list = $('<ul>').html(content).addClass('dropdown')
        return $list
      })

      $toggle.clone().insertAfter($list)
    })
}

/**
 * Set up CMS sidebar draggable items. It is set up every time the sidebar is updated.
 */
function setUpSidebarDrag () {
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Imported on top
  $('[data-behavior~=drag]').draggable!({
    handle: ':not(.cms-section > i:first-child)',
    helper: (event) => { // TODO: might be better to use built-in helper "clone".)
      const li = $(event.currentTarget as HTMLLIElement)
      const list = $('<ul>', { class: 'cms-sidebar-listing' }).appendTo('#cms-sidebar')

      return li.clone()
        .prependTo(list)
        .addClass('dragged')[0]
    },
    revert: 'invalid'
  })
}

/**
 * Set up sections' Contents drop. It is set up every time a new section is selected.
 */
function setUpSectionDrop () {
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Imported on top
  $('#subsections-container').droppable!({
    hoverClass: 'subsection-hover',
    drop: (_event, ui) => {
      const { type, id: value, param } = ui.helper[0].dataset as { type: string; id: string; param: string }
      const id = `${type.toLowerCase()}-${value}`

      $('#subsections-container thead').remove()
      $('#subsections-container tbody').append(`
        <tr id="${id}">
          <td>${ui.helper.children('a').text()}</td>
          <td>${type}</td>
          <td><a href="#" onclick="$('#${id}').remove()">Remove</a></td>
          <input
            type="hidden"
            name="cms_section[${param.toLowerCase()}_ids][]"
            value="${value}"
          />
        </tr>
      `)
    }
  })
}

/**
 * Set up CMS template editor's tabs: Draft and Published.
 */
function setUpEditorTabs () {
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Imported on top
  $('div#cms-template-editor').tabs!()
}

/**
 * Content type input and Liquid Enabled checkbox affects the editor's theme.
 * Listen for changes in this inputs and fire change event that will update Codemirror mode
 * accordingly. Codemirror's own listener here: app/views/provider/admin/cms/_codemirror.html.erb
 */
function setUpContentTypeLiquidEnabledListener () {
  jQuery1(document).on('change', '#cms_template_content_type, #cms_template_liquid_enabled', () => {
    const contentTypeInput = document.querySelector<HTMLInputElement>('#cms_template_content_type')
    const liquidEnabledInput = document.querySelector<HTMLInputElement>('#cms_template_liquid_enabled')

    if (!contentTypeInput || !liquidEnabledInput) {
      throw new Error('change event was somehow triggered before Advanced options was ready')
    }

    const contentType = contentTypeInput.value
    const liquidEnabled = liquidEnabledInput.checked

    const codemirror = jQuery1('#cms_template_draft').data('codemirror') as EditorFromTextArea

    jQuery1(codemirror).trigger('change', [contentType, liquidEnabled])
  })

  jQuery1(document).on('click', 'a[href^="#cms-set-content-type-"]', (event) => {
    event.stopImmediatePropagation()
    event.preventDefault()

    const { mimeType } = (event.target as HTMLAnchorElement).dataset as { mimeType: string }
    const input = jQuery1('#cms_template_content_type')

    if (input.val() !== mimeType) {
      input.val(mimeType).trigger('change')
    }
  })
}

function setUpRevertButton () {
  document.querySelectorAll<HTMLAnchorElement>('a[href="#cms-template-revert"]')
    .forEach((revertLink) => {
      revertLink.addEventListener('click', (event) => {
        event.stopImmediatePropagation()
        event.preventDefault()

        const draft = jQuery1('#cms_template_draft').data('codemirror') as EditorFromTextArea
        const published = jQuery1('#cms_template_published').data('codemirror') as EditorFromTextArea

        draft.setValue(published.getValue())
        flash.notice('Reverted draft to a currently published version.')

        const lines = $('.CodeMirror-lines')
        lines.animate({ opacity: 0.2 }, 500, () => { lines.animate({ opacity: 1.0 }) })

        const save = confirm('Your draft is now reset to latest published version.\nDo you want to save your changes?')

        if (save) {
          // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Where there's a revert there's a save
          document.getElementById('codemirror_save_button')!.click()
        }
      })
    })
}

function setUpRemoveFromSectionAction () {
  $(document).on('click', '.remove-from-section', (event) => {
    event.stopImmediatePropagation()
    event.preventDefault()

    const row = $(event.target).closest('tr[id]')
    row.fadeOut(() => { row.remove() })
  })
}
