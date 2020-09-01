// Use global jQuery in order to use jquery-colorbox

// TODO: this needs fixing, probably remove colorbox altogether

// TODO: remove old bulk_operations.coffee

const selectAllChecboxSelector = 'thead [type="checkbox"].select-all'
const singleCheckboxSelector = 'tbody input[type=checkbox]'
const singleCheckboxSelectorSelected = 'tbody input[type=checkbox]:checked'
const bulkSelector = '#bulk-operations'
const tableSelector = 'table.data'
const countSelector = '#bulk-operations .count'

function onSelectAll () {
  const isChecked = $(this).is(':checked')
  $(tableSelector)
    .find(singleCheckboxSelector)
    .prop('checked', isChecked)

  updateCount()
}

function updateCount () {
  const selectTotalEntries = $('#bulk-operations a.select-total-entries')
  const bulk = $(bulkSelector)

  const count = $(singleCheckboxSelector).length
  const selectedCount = $(singleCheckboxSelectorSelected).length
  if (selectedCount > 0) {
    bulk.slideDown()
    $(countSelector).text(selectedCount)

    if (selectedCount === count) {
      selectTotalEntries.show()
    } else {
      selectTotalEntries.hide()
      selectTotalEntries.text(selectTotalEntries.data('default-text'))
      selectTotalEntries.removeAttr('data-selected-total-entries')
    }
  } else {
    bulk.slideUp()
  }

  $(selectAllChecboxSelector).prop('checked', selectedCount === count)
}

function onSelectOne () {
  updateCount()
}

const prepareCheckboxes = function () {
  const table = $(tableSelector)
  table
    .find(selectAllChecboxSelector)
    .on('change', onSelectAll)

  table
    .find(singleCheckboxSelector)
    .on('change', onSelectOne)
}

const prepareOperationsModal = function () {
  $(bulkSelector)
    .on('bulk:success', function () {
      $.colorbox({
        html: '<h1>Action completed successfully</h1>',
        title: 'Bulk operation completed successfully'
      })
    })
    .find('.operation').each(function () {
      const operation = $(this)
      const button = operation.find('button')
      const description = operation.closest('.description').text()

      button.colorbox({
        href: function () {
          const urlParts = [button.data('url'), $(singleCheckboxSelectorSelected).serialize()]
          let url = null

          // url address might already inludes some parameters
          if (urlParts[0].indexOf('?') > -1) {
            url = urlParts.join('&')
          } else {
            url = urlParts.join('?')
          }

          // if total entries action was selected
          // add selected_total_entries parameter to the url
          const selectTotalEntries = $('#bulk-operations a.select-total-entries')
          if (selectTotalEntries.length && selectTotalEntries.attr('data-selected-total-entries')) {
            url += '&selected_total_entries=true'
          }

          /* WORKAROUND */
          // Since colorbox is already implemented, this will inject PF classes and elements in order to transform it into a PF modal.
          const overlay = document.getElementById('cboxOverlay')
          overlay.removeAttribute('style')
          overlay.classList.add('pf-c-backdrop')

          const modal = document.querySelector('#colorbox[role="dialog"]')
          modal.removeAttribute('style')
          modal.classList.add('pf-c-modal-box')
          /* END OF WORKAROUND */

          return url
        },
        title: description,
        autoDimensions: true,
        overlayShow: true,
        hideOnOverlayClick: false,
        hideOnContentClick: false,
        enableEscapeButton: false,
        showCloseButton: true
      })
    })
}

const prepareSelectTotalEntries = function () {
  $('#bulk-operations a.select-total-entries').on('click', function (e) {
    e.preventDefault()

    const $this = $(this)
    const attrName = 'data-selected-total-entries'

    if ($this.attr(attrName)) {
      // user has already selected total entries
      $this.removeAttr(attrName)
      // set back the default text
      $this.text($this.data('default-text'))
    } else {
      // save information that user has selected total entries
      $this.attr(attrName, true)
      // save default text
      $this.data('default-text', $this.text())
      // new text for the link
      let newText = '(only select the '
      newText += $('table.data tr.selected').length
      newText += ' '
      newText += $this.data('association-name')
      newText += ' on this page)'

      $this.text(newText)
    }
  })
}

document.addEventListener('DOMContentLoaded', () => {
  prepareCheckboxes()
  prepareOperationsModal()
  prepareSelectTotalEntries()
})
