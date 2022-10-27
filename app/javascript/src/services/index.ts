import { toggle, moveState } from 'utilities/toggle'
import { migrate } from 'services/migrate'

export function initialize (): void{
  migrate()
  const list = document.querySelectorAll('.service-widget')

  for (const wrapper of Array.from(list)) {
    const toggler = wrapper.querySelector('.title-toggle')

    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- FIXME: double check and remove wrapper if possible
    if (toggler && wrapper) {
      moveState(wrapper.id, 'packed', 'is-closed')
      toggle(wrapper.id, wrapper.classList, toggler, 'is-closed')
    }
  }
}

export default initialize
