/* eslint-disable @typescript-eslint/no-invalid-this */
document.addEventListener('DOMContentLoaded', () => {
  const handleCheckboxes = function () {
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

  const prepareOperations = function () {
    const operations = $('#bulk-operations')
    operations
      .on('bulk:success', function () {
        // @ts-expect-error -- Missing types for colorbox
        // eslint-disable-next-line @typescript-eslint/no-unsafe-call
        $.colorbox({
          html: '<h1>Action completed successfully</h1>',
          title: 'Bulk operation completed successfully'
        })
      })
      .find('.operation')
      .each(function () {
        const operation = $(this)
        $(this).wrapInner('<button>')
        // @ts-expect-error -- Missing types for colorbox
        // eslint-disable-next-line @typescript-eslint/no-unsafe-call
        $(this).find('button').colorbox({
          href: function () {
            const urlParts = [operation.data('url'), $('table tbody .select :checked').serialize()]
            let url = null

            // url address might already inludes some parameters
            // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
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

            return url
          },
          title: operation.next('.description').text(),
          autoDimensions: true,
          overlayShow: true, // cannot use modal, because its setting cannot be overriden
          hideOnOverlayClick: false,
          hideOnContentClick: false,
          enableEscapeButton: false,
          showCloseButton: true
        })
      })
  }

  const handleSelectTotalEntries = function () {
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

  $(function () {
    prepareOperations()
    handleCheckboxes()
    handleSelectTotalEntries()
  })
})
