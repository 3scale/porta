import toggle from 'utilities/toggle'
import migrate from 'services/migrate'

export function initialize () {
  migrate()
  let list = document.querySelectorAll('.DashboardSection--service')

  for (let wrapper of Array.from(list)) {
    let toggler = wrapper.querySelector('.DashboardSection-toggle')
    let element = wrapper

    if (toggler && element) {
      toggle(element.id, element.classList, toggler, 'is-closed')
    }
  }
}

export default initialize
