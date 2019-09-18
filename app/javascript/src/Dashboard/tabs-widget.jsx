const TAB_PRODUCTS = 'tab-products'
const TAB_BACKENDS = 'tab-backends'

function updateActiveTab (activeTab, inactiveTab) {
  activeTab.classList.add('active')
  inactiveTab.classList.remove('active')
}

export function initialize () {
  const productsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_PRODUCTS}`)
  const backendsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_BACKENDS}`)
  const productsContainer = document.querySelector(`.DashboardNavigation-tabs--content #products`)
  const backendsContainer = document.querySelector(`.DashboardNavigation-tabs--content #backends`)
  const tabsBar = document.querySelector('.DashboardSection--services > .pf-c-tabs')
  const productsTab = tabsBar.querySelector(`button#${TAB_PRODUCTS}`)
  productsTab.addEventListener('click', () => {
    productsTab.parentElement.classList.add('pf-m-current')
    productsInput.setAttribute('checked', true)

    backendsTab.parentElement.classList.remove('pf-m-current')
    backendsInput.removeAttribute('checked')

    document.cookie = `dashboard_current_tab=${TAB_PRODUCTS}`
    updateActiveTab(productsContainer, backendsContainer)
  })

  const backendsTab = tabsBar.querySelector(`button#${TAB_BACKENDS}`)
  backendsTab.addEventListener('click', () => {
    backendsTab.parentElement.classList.add('pf-m-current')
    backendsInput.setAttribute('checked', true)

    productsTab.parentElement.classList.remove('pf-m-current')
    productsInput.removeAttribute('checked')

    document.cookie = `dashboard_current_tab=${TAB_BACKENDS}`
    updateActiveTab(backendsContainer, productsContainer)
  })
}
