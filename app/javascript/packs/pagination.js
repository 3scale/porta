function setupPageNavigation (pagination) {
  const url = new URL(pagination.dataset.url)

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  pagination
    .querySelectorAll('.pf-c-pagination__nav-control .pf-c-button')
    .forEach(button => {
      const { page } = button.dataset
      button.addEventListener('click', () => goToPage(page))
    })

  pagination
    .querySelector('.pf-c-form-control')
    .addEventListener('keyup', (ev) => {
      if (ev.key === 'Enter') {
        goToPage(ev.target.value)
      }
    })
}

function setupPerPageSelection (pagination) {
  const url = new URL(pagination.dataset.url)

  const selectPerPage = (perPage) => {
    url.searchParams.set('per_page', perPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const perPageWidget = pagination.querySelector('.pf-c-options-menu')
  const perPageDropdown = perPageWidget.querySelector('.pf-c-options-menu__menu')
  perPageWidget
    .querySelector('.pf-c-options-menu__toggle-button')
    .addEventListener('click', () => {
      perPageDropdown.toggleAttribute('hidden')
    })

  perPageWidget
    .querySelectorAll('.pf-c-options-menu__menu-item')
    .forEach(option => {
      option.addEventListener('click', () => {
        const { perPage } = option.dataset
        perPageDropdown.toggleAttribute('hidden')
        selectPerPage(perPage)
      })
    })

  // TODO: close when escape or click outside
  // document.addEventListener('keyup', (ev) => {
  //   if (ev.key === 'Escape') {
  //     perPageDropdown.addAttribute('hidden')
  //   }
  // })
}

document.addEventListener('DOMContentLoaded', () => {
  const pagination = document.querySelector('.pf-c-pagination')

  setupPageNavigation(pagination)
  setupPerPageSelection(pagination)
})
