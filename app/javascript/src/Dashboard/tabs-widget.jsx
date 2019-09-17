const TAB_PRODUCTS = 'tab-products'
const TAB_BACKENDS = 'tab-backends'

export function initialize () {
  const productsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_PRODUCTS}`)
  const backendsInput = document.querySelector(`.DashboardNavigation-tabs--content > input#${TAB_BACKENDS}`)

  const tabsBar = document.querySelector('.DashboardSection--services > .pf-c-tabs')
  const productsTab = tabsBar.querySelector(`button#${TAB_PRODUCTS}`)
  productsTab.addEventListener('click', () => {
    productsTab.parentElement.classList.add('pf-m-current')
    productsInput.setAttribute('checked', true)

    backendsTab.parentElement.classList.remove('pf-m-current')
    backendsInput.removeAttribute('checked')

    document.cookie = `dashboard_current_tab=${TAB_PRODUCTS}`
  })

  const backendsTab = tabsBar.querySelector(`button#${TAB_BACKENDS}`)
  backendsTab.addEventListener('click', () => {
    backendsTab.parentElement.classList.add('pf-m-current')
    backendsInput.setAttribute('checked', true)

    productsTab.parentElement.classList.remove('pf-m-current')
    productsInput.removeAttribute('checked')

    document.cookie = `dashboard_current_tab=${TAB_BACKENDS}`
  })

  // const tabs = document.querySelectorAll('label[for^="tab-"]')
  // const inputs = document.querySelectorAll('input[name="apiap-tabs"]')

  // // NodeList.foreEach not supported in IE11
  // for (const i of inputs) {
  //   i.addEventListener('change', toggleCurrentTab)
  // }

  // function toggleCurrentTab (e: any) {
  //   document.cookie = `dashboard_current_tab=${e.currentTarget.id}`
  //   for (const t of tabs) {
  //     t.classList.toggle('current-tab')
  //   }
  // }
}
