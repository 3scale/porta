import toggle, { moveState } from 'utilities/toggle'
import migrate from 'services/migrate'

export function initialize () {
  migrate()
  let list = document.querySelectorAll('.service-widget')

  for (let wrapper of Array.from(list)) {
    let toggler = wrapper.querySelector('.title-toggle')

    if (toggler && wrapper) {
      moveState(wrapper.id, 'packed', 'is-closed')
      toggle(wrapper.id, wrapper.classList, toggler, 'is-closed')
    }
  }
}

export default initialize
