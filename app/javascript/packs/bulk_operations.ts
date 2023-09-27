/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable @typescript-eslint/no-invalid-this */
document.addEventListener('DOMContentLoaded', () => {
  const attrName = 'data-selected-total-entries'

  const colorboxOpts = {
    autoDimensions: true,
    overlayShow: true, // cannot use modal, because its setting cannot be overridden
    hideOnOverlayClick: false,
    hideOnContentClick: false,
    enableEscapeButton: false,
    showCloseButton: true
  }

  function hrefFor (element: HTMLElement) {
    const url = element.dataset.url!

    // url address might already include some parameters
    const connector = url.includes('?') ? '&' : '?'
    let href = url.concat(connector, $('table tbody .select :checked').serialize())

    const selectTotalEntries = document.querySelector<HTMLAnchorElement>('#bulk-operations a.select-total-entries')
    if (selectTotalEntries?.hasAttribute(attrName)) {
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
          updateSelectAllCheckbox()
        })
      })
  }

  function updateSelectAllCheckbox () {
    const selected = document.querySelectorAll('table tbody tr.selected').length
    const unselected = document.querySelectorAll('table tbody tr:not(.selected').length

    const checkbox = document.querySelector<HTMLInputElement>('table thead .select .select-all')!

    checkbox.indeterminate = selected > 0 && unselected > 0
    checkbox.checked = unselected === 0
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

    document.querySelectorAll<HTMLElement>('#bulk-operations .operation')
      .forEach((element) => {
        $(element).wrapInner('<button>')

        element.querySelector<HTMLButtonElement>('button')!
          .addEventListener('click', () => {
            // @ts-expect-error -- Missing types for colorbox
            // eslint-disable-next-line @typescript-eslint/no-unsafe-call
            $.colorbox({
              ...colorboxOpts,
              title: element.nextElementSibling!.textContent,
              href: hrefFor(element)
            })
          })
      })
  }

  function handleSelectTotalEntries () {
    const selectTotalEntries = document.querySelector<HTMLAnchorElement>('#bulk-operations a.select-total-entries')

    if (!selectTotalEntries) {
      return
    }

    selectTotalEntries.addEventListener('click', function (e) {
      e.preventDefault()

      if (selectTotalEntries.hasAttribute(attrName)) {
        selectTotalEntries.removeAttribute(attrName)
        selectTotalEntries.innerText = selectTotalEntries.dataset.defaultText!
      } else {
        selectTotalEntries.setAttribute(attrName, 'true')

        const newText = `(only select the ${$('table tr.selected').length} ${selectTotalEntries.dataset.associationName!} on this page)`
        selectTotalEntries.innerText = newText
      }
    })
  }

  prepareOperations()
  prepareSelectAllCheckbox()
  prepareSingleCheckboxes()
  handleSelectTotalEntries()
})
