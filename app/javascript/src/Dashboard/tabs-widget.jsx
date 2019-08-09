const CURRENT_TAB_CLASS = 'current-tab'

export function initialize () {
  const tabProducts = document.querySelector('label[for="tab-products"]')
  const tabBackends = document.querySelector('label[for="tab-backends"]')

  const inputProducts = document.querySelector('input#tab-products')
  const inputBackends = document.querySelector('input#tab-backends')

  inputProducts.addEventListener('change', () => {
    tabProducts.classList.add(CURRENT_TAB_CLASS)
    tabBackends.classList.remove(CURRENT_TAB_CLASS)
  })

  inputBackends.addEventListener('change', () => {
    tabBackends.classList.add(CURRENT_TAB_CLASS)
    tabProducts.classList.remove(CURRENT_TAB_CLASS)
  })
}
