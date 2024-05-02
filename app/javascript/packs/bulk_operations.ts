/* eslint-disable @typescript-eslint/no-non-null-assertion */
const jquery1 = window.$

document.addEventListener('DOMContentLoaded', () => {
  const dataSelectedTotal = 'data-selected-total-entries'
  const dataDefaultText = 'data-default-text'
  const dataSelectedTotalEntries = 'data-selected-total-entries'

  const findSelectAllCheckbox = () => document.querySelector<HTMLInputElement>('table thead .select .select-all')
  const findSelectTotalEntries = () => document.querySelector<HTMLAnchorElement>('#bulk-operations a.select-total-entries')
  const countUnselectedRows = () => document.querySelectorAll('table tbody tr:not(.selected').length

  function hrefFor (url: string) {
    // url address might already include some parameters
    const connector = url.includes('?') ? '&' : '?'
    let href = url.concat(connector, jquery1('table tbody .select :checked').serialize())

    const selectTotalEntries = findSelectTotalEntries()
    if (selectTotalEntries?.hasAttribute(dataSelectedTotal)) {
      href += '&selected_total_entries=true'
    }

    return href
  }

  function prepareSelectAllCheckbox () {
    findSelectAllCheckbox()!
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
    const unselected = countUnselectedRows()

    const checkbox = findSelectAllCheckbox()!

    checkbox.indeterminate = selected > 0 && unselected > 0
    checkbox.checked = unselected === 0
  }

  function setSelectedCount (count: number | string) {
    document.querySelector<HTMLSpanElement>('#bulk-operations .count')!.innerText = count.toString()
  }

  function updateBulkOperationsCard () {
    const bulk = jquery1('#bulk-operations')
    const selected = selectedRows()

    if (selected > 0) {
      bulk.slideDown()
      setSelectedCount(selected)

      const selectTotalEntries = findSelectTotalEntries()
      if (selectTotalEntries) {
        const isAllSelected = countUnselectedRows() === 0
        if (isAllSelected) {
          selectTotalEntries.classList.remove('hidden')
        } else {
          selectTotalEntries.classList.add('hidden')
          selectTotalEntries.innerText = selectTotalEntries.getAttribute(dataDefaultText)!
          selectTotalEntries.removeAttribute(dataSelectedTotalEntries)
        }
      }
    } else {
      bulk.slideUp()
    }
  }

  function prepareOperations () {
    document.querySelectorAll<HTMLDataElement>('#bulk-operations dt.operation')
      .forEach(dt => {
        dt.querySelector('button')!
          .addEventListener('click', () => {
            jquery1.colorbox({
              title: dt.nextElementSibling!.textContent,
              href: hrefFor(dt.dataset.url!)
            })
          })
      })
  }

  function selectedRows () {
    return document.querySelectorAll('table tr.selected').length
  }

  prepareOperations()
  prepareSelectAllCheckbox()
  prepareSingleCheckboxes()
})
