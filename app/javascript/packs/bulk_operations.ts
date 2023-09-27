/* eslint-disable @typescript-eslint/no-non-null-assertion */
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

  function prepareSelectAllCheckbox () {
    document.querySelector<HTMLInputElement>('table thead .select .select-all')!
      .addEventListener('change', (event) => {
        const checked = (event.target as HTMLInputElement).checked

        document.querySelectorAll<HTMLTableRowElement>('table tbody tr')
          .forEach((row) => {
            row.classList.toggle('selected', checked)

            const checkbox = row.querySelector<HTMLInputElement>('.select input[type=checkbox]')!
            checkbox.checked = checked
            checkbox.setAttribute('checked', checked.toString())
          })

        updateBulkOperationsCard()
      })
  }

  function prepareSingleCheckboxes () {
    document.querySelectorAll<HTMLInputElement>('table tbody .select input[type=checkbox]')
      .forEach(checkbox => {
        checkbox.addEventListener('change', () => {
          const row = checkbox.closest('tr')!
          row.classList.toggle('selected', checkbox.checked)

          updateBulkOperationsCard()
        })
      })
  }

  function setSelectedCount (count: number) {
    document.querySelector<HTMLSpanElement>('#bulk-operations .count')!.innerText = count.toString()
  }

  function updateBulkOperationsCard () {
    const bulk = $('#bulk-operations')
    const selected = document.querySelectorAll('table tbody tr.selected').length

    if (selected > 0) {
      bulk.slideDown()
      setSelectedCount(selected)

      const selectTotalEntries = document.querySelector<HTMLAnchorElement>('#bulk-operations a.select-total-entries')
      if (selectTotalEntries) {
        const isAllSelected = document.querySelectorAll('table tbody tr:not(.selected').length === 0
        if (isAllSelected) {
          selectTotalEntries.classList.remove('hidden')
        } else {
          selectTotalEntries.classList.add('hidden')
          selectTotalEntries.innerText = selectTotalEntries.dataset.defaultText!
          selectTotalEntries.removeAttribute('data-selected-total-entries')
        }
      }
    } else {
      bulk.slideUp()
    }
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
  prepareSelectAllCheckbox()
  prepareSingleCheckboxes()
  handleSelectTotalEntries()
})
