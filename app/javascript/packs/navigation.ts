import { hideAllToggleable, toggleNavigation } from 'Navigation/utils/toggle_navigation'

document.addEventListener('DOMContentLoaded', () => {
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

  document.body.addEventListener('click', (e: Event) => {
    if ((e.target as HTMLInputElement).type !== 'search') {
      hideAllToggleable()
    }
  }, eventOptions)

  addClickEventToCollection(togglers, function (e: Event) {
    e.stopPropagation()
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: can we safely assume the target is there? Also, why currentTarget here but target above?
    toggleNavigation(e.currentTarget!)
    e.preventDefault()
  })

  addClickEventToCollection(vertNavTogglers, function () {
    const store = window.localStorage
    // @ts-expect-error FIXME: should or should not? Figure it out
    const shouldVertNavCollapse = !JSON.parse((store.isVerticalNavCollapsed as string) || false)

    document.querySelector('.vertical-nav')
      ?.classList
      .toggle('collapsed')

    store.isVerticalNavCollapsed = shouldVertNavCollapse
  })
})
