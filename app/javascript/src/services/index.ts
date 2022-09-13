import toggle, { moveState } from 'utilities/toggle'
import migrate from 'services/migrate'

export function initialize () {
  migrate()
  const list = document.querySelectorAll('.service-widget')

  for (const wrapper of Array.from(list)) {
    const toggler = wrapper.querySelector('.title-toggle')

    if (toggler && wrapper) {
      moveState(wrapper.id, 'packed', 'is-closed')
      toggle(wrapper.id, wrapper.classList, toggler, 'is-closed')
    }
  }
}

export default initialize
