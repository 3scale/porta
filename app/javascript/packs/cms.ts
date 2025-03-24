import $ from 'jquery'
import 'jquery-ui/ui/widgets/droppable'
import 'jquery-ui/ui/widgets/draggable'
import 'jquery-ui/ui/widgets/tabs'
import 'jquery-pjax'

import * as flash from 'utilities/flash'

import type { EditorFromTextArea } from 'codemirror'

const jQuery1 = window.$

/**
 * Called every time a CMS section is selected in the sidebar, including first render.
 */
jQuery1(document).on('cms-template:init', () => {
  advanceOptionsToggle()
  setUpSectionDrop()
  setUpEditorTabs()
  setUpPjax()

  jQuery1('#cms_template_content_type, #cms_template_liquid_enabled').trigger('change')
})

jQuery1(document).on('cms-sidebar:update', () => {
  setUpSidebarDrag()
  setUpDropdownButtonOpen()
})

document.addEventListener('DOMContentLoaded', () => {
  setUpContentTypeLiquidEnabledListener()
  setUpRevertButton()
  setUpRemoveFromSectionAction()
  setUpDropdownButtonClose()
  setUpPreviewButton()

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
window.CMS = {
  partialPaths: (paths) => {
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

/**
 * PJAX is a jQuery plugin that allows rails to render HTML into the current page, without loading
 * the whole page. It is used only by Sidebar class, to give the CMS a page-less experience. It's
 * definitely tech debt and modern rails applications will use turbolinks, but right now we stick
 * to it for convenience.
 * PJAX automatically extends window.$, that is 1.11.3 (JQueryStaticV1Plugins)
 */
function setUpPjax () {
  jQuery1(document).pjax('#cms-sidebar .cms-sidebar-listing a', '#tab-content', { timeout: 3000 })

  jQuery1(document)
    .on('pjax:send', () => {
      const spinner = document.createElement('img')
      spinner.src = '/assets/ajax-loader.gif'

      window.ThreeScale.showSpinner()
    })
    .on('pjax:complete', () => {
      window.ThreeScale.hideSpinner()
    })
    .on('pjax:end', (event) => {
      jQuery1(event.target).trigger('cms-template:init')
    })
}

/**
 * The CMS features 4 dropdown buttons: New button, Preview, Publish and Save. Html is rendered
 * by "/provider/admin/cms/dropdown" partial and its functionality is given by this method everytime a new template is
 * selected (cms-sidebar:update event).
 *
 * The event handler has to be defined with jQuery because at the time this method is called, the
 * CMS content is not yet rendered and document.querySelector would find nothing.
 */
function setUpDropdownButtonOpen () {
  $(document).on('click', '.dropdown-toggle', (event) => {
    closeAllDropdowns(event.target as HTMLButtonElement)

    const toggle = $(event.currentTarget)
    toggle.parents('.pf-c-dropdown').toggleClass('pf-m-expanded')

    return false
  })
}

/**
 * Complementary to setUpDropdownButtonClick, this listener will close any expanded dropdown when
 * clicking anywhere.
 */
function setUpDropdownButtonClose () {
  document.addEventListener('mousedown', (event) => {
    closeAllDropdowns(event.target as HTMLElement)
  })
}

function closeAllDropdowns (exception?: HTMLElement) {
  document.querySelectorAll('.pf-c-dropdown.pf-m-expanded')
    .forEach(dropdown => {
      if (exception && dropdown.contains(exception)) {
        return
      }
      dropdown.classList.remove('pf-m-expanded')
    })
}

/**
 * Set up CMS Preview button to act as a link
 */
function setUpPreviewButton () {
  $(document).on('click', '#cms-preview-button button.pf-c-dropdown__toggle-button:not(.dropdown-toggle)', (event) => {
    const previewButton = event.target as HTMLButtonElement
    const url = previewButton.dataset.url
    if (url) {
      window.open(url)
    }
    return false
  })
}
