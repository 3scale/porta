/* eslint-disable @typescript-eslint/no-invalid-this */
document.addEventListener('DOMContentLoaded', () => {
  const colorboxOpts = {
    autoDimensions: true,
    overlayShow: true, // cannot use modal, because its setting cannot be overridden
    hideOnOverlayClick: false,
    hideOnContentClick: false,
    enableEscapeButton: false,
    showCloseButton: true
  }

  function hrefFor (element: HTMLElement) {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const url = element.dataset.url!

    // url address might already include some parameters
    const connector = url.includes('?') ? '&' : '?'
    let href = url.concat(connector, $('table tbody .select :checked').serialize())

    const selectTotalEntries = document.querySelector<HTMLElement>('#bulk-operations a.select-total-entries')
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    if (selectTotalEntries?.dataset.selectTotalEntries === 'true') {
      href += '&selected_total_entries=true'
    }

    return href
  }

  function handleCheckboxes () {
    const table = $('table')
    const selectTotalEntries = $('#bulk-operations a.select-total-entries')

    // select all checkbox
    table.find('thead .select .select-all').on('change', function () {
      $(this).closest('table')
        .find('tbody .select input[type=checkbox]')
        .attr('checked', $(this).is(':checked').toString())
        .trigger('change')
    })

    // single checkbox
    table.find('tbody .select input[type=checkbox]').on('change', function () {
      const $this = $(this)
      const row = $this.closest('tr')
      const bulk = $('#bulk-operations')

      if ($this.is(':checked')) {
        row.addClass('selected')
      } else {
        row.removeClass('selected')
      }

      const selected = row.closest('tbody, table').find('.selected').length

      if (selected > 0) {
        // show bulk operations section
        bulk.slideDown()
        // show selected count
        bulk.find('.count').text(selected)
        // if user has selected all checkboxes -> show select total entries action
        if (selected == table.find('tbody .select input[type=checkbox]').length) {
          selectTotalEntries.show()
        } else {
          // total entries action back to the default state
          selectTotalEntries.hide()
          selectTotalEntries.text(selectTotalEntries.data('default-text') as string)
          selectTotalEntries.removeAttr('data-selected-total-entries')
        }
      } else {
        // hide bulk operations section
        bulk.slideUp()
      }
    })
  }

  function prepareOperations () {
    $('#bulk-operations')
      .on('bulk:success', function () {
        // @ts-expect-error -- Missing types for colorbox
        // eslint-disable-next-line @typescript-eslint/no-unsafe-call
        $.colorbox({ // TODO: replace this with a flash
          html: '<h1>Action completed successfully</h1>',
          title: 'Bulk operation completed successfully'
        })
      })
      .find('.operation')
      .each(function (_i, element) {
        // eslint-disable-next-line @typescript-eslint/no-unsafe-call
        $(element)
          .wrapInner('<button>')
          .find('button')
          // @ts-expect-error -- Missing types for colorbox
          .colorbox({
            ...colorboxOpts,
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            title: element.nextElementSibling!.textContent,
            href: hrefFor(element)
          })
      })
  }

  function handleSelectTotalEntries () {
    $('#bulk-operations a.select-total-entries').on('click', function (e) {
      e.preventDefault()

      const $this = $(this)
      const attrName = 'data-selected-total-entries'

      if ($this.attr(attrName)) {
        // user has already selected total entries
        $this.removeAttr(attrName)
        // set back the default text
        $this.text($this.data('default-text') as string)
      } else {
        // save information that user has selected total entries
        $this.attr(attrName, 'true')
        // save default text
        $this.data('default-text', $this.text())
        // new text for the link
        let newText = '(only select the '
        newText += $('table tr.selected').length
        newText += ' '
        newText += $this.data('association-name')
        newText += ' on this page)'

        $this.text(newText)
      }

    })
  }

  prepareOperations()
  handleCheckboxes()
  handleSelectTotalEntries()
})
