import { hideAllToggleable, toggleNavigation } from 'Navigation/utils/toggle_navigation'

document.addEventListener('DOMContentLoaded', () => {
  const store = window.localStorage
  const togglers = document.getElementsByClassName('u-toggler') as HTMLCollectionOf<HTMLElement>
  const vertNavTogglers = document.getElementsByClassName('vert-nav-toggle') as HTMLCollectionOf<HTMLElement>
  const eventOptions = {
    capture: true,
    passive: false,
    useCapture: true
  }

  function addClickEventToCollection (collection: HTMLCollectionOf<HTMLElement>, handler: (e: Event) => void) {
    for (const item of Array.from(collection)) {
      item.addEventListener('click', handler, eventOptions)
    }
  }

  document.body.addEventListener('click', (e: any /* Event of some sort */) => {
    if (e.target.type !== 'search') {
      hideAllToggleable()
    }
  }, eventOptions)

  addClickEventToCollection(togglers, function (e) {
    e.stopPropagation()
    toggleNavigation(e.currentTarget as EventTarget)
    e.preventDefault()
  })

  addClickEventToCollection(vertNavTogglers, function () {
    const shouldVertNavCollapse = !JSON.parse(store.isVerticalNavCollapsed || false)

    document.querySelector('.vertical-nav')
      ?.classList
      .toggle('collapsed')

    store.isVerticalNavCollapsed = shouldVertNavCollapse
  })
})
