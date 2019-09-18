const TAB_PRODUCTS = 'tab-products'
const TAB_BACKENDS = 'tab-backends'

function updateActiveTab (activeTab, inactiveTab) {
  activeTab.classList.add('active')
  inactiveTab.classList.remove('active')
}

function setCurrentTab (currentTab, currentInput, notCurrentTab, notCurrentInput) {
  currentTab.parentElement.classList.add('pf-m-current')
  currentInput.setAttribute('checked', true)
  notCurrentTab.parentElement.classList.remove('pf-m-current')
  notCurrentInput.removeAttribute('checked')
}

export function initialize () {
  const productsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_PRODUCTS}`)
  const backendsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_BACKENDS}`)
  const productsContainer = document.querySelector(`.DashboardNavigation-tabs--content #products`)
  const backendsContainer = document.querySelector(`.DashboardNavigation-tabs--content #backends`)
  const tabsBar = document.querySelector('.DashboardSection--services > .pf-c-tabs')
  const productsTab = tabsBar.querySelector(`button#${TAB_PRODUCTS}`)

  productsTab.addEventListener('click', () => {
    setCurrentTab(productsTab, productsInput, backendsTab, backendsInput)
    document.cookie = `dashboard_current_tab=${TAB_PRODUCTS}`
    updateActiveTab(productsContainer, backendsContainer)
  })

  const backendsTab = tabsBar.querySelector(`button#${TAB_BACKENDS}`)
  backendsTab.addEventListener('click', () => {
    setCurrentTab(backendsTab, backendsInput, productsTab, productsInput)
    document.cookie = `dashboard_current_tab=${TAB_BACKENDS}`
    updateActiveTab(backendsContainer, productsContainer)
  })
}
