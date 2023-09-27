/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable @typescript-eslint/no-invalid-this */
document.addEventListener('DOMContentLoaded', () => {
  const dataSelectedTotal = 'data-selected-total-entries'
  const dataTotalEntries = 'data-total-entries'
  const dataModelName = 'data-association-name'
  const dataDefaultText = 'data-default-text'

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
    if (selectTotalEntries?.hasAttribute(dataSelectedTotal)) {
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
    const selected = selectedRows()
    const unselected = document.querySelectorAll('table tbody tr:not(.selected').length

    const checkbox = document.querySelector<HTMLInputElement>('table thead .select .select-all')!

    checkbox.indeterminate = selected > 0 && unselected > 0
    checkbox.checked = unselected === 0
  }

  function setSelectedCount (count: number | string) {
    document.querySelector<HTMLSpanElement>('#bulk-operations .count')!.innerText = count.toString()
  }

  function updateBulkOperationsCard () {
    const bulk = $('#bulk-operations')
    const selected = selectedRows()

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
          selectTotalEntries.innerText = selectTotalEntries.getAttribute(dataDefaultText)!
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
        element.innerHTML = `<button>${element.innerText}</button>`

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

      const selected = selectedRows()

      if (selectTotalEntries.hasAttribute(dataSelectedTotal)) {
        selectTotalEntries.removeAttribute(dataSelectedTotal)
        selectTotalEntries.innerText = selectTotalEntries.getAttribute(dataDefaultText)!
        setSelectedCount(selected)
      } else {
        selectTotalEntries.setAttribute(dataSelectedTotal, 'true')

        const newText = `(only select the ${selected} ${selectTotalEntries.getAttribute(dataModelName)!} on this page)`
        selectTotalEntries.innerText = newText

        setSelectedCount(selectTotalEntries.getAttribute(dataTotalEntries)!)
      }
    })
  }

  function selectedRows () {
    return document.querySelectorAll('table tr.selected').length
  }

  prepareOperations()
  prepareSelectAllCheckbox()
  prepareSingleCheckboxes()
  handleSelectTotalEntries()
})
