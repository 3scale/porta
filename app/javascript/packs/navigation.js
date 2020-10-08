import '@babel/polyfill'

import { toggleNavigation, hideAllToggleable } from 'Navigation/utils/toggle_navigation'

document.addEventListener('DOMContentLoaded', () => {
  let store = window.localStorage
  const togglers = document.getElementsByClassName('u-toggler')
  const vertNavTogglers = document.getElementsByClassName('vert-nav-toggle')
  const eventOptions = {
    capture: true,
    passive: false,
    useCapture: true
  }

  function addClickEventToCollection (collection, handler) {
    for (let item of collection) {
      item.addEventListener('click', handler, eventOptions)
    }
  }

  document.body.addEventListener('click', function (e) {
    if (e.target.type !== 'search') {
      hideAllToggleable()
    }
  }, eventOptions)

  addClickEventToCollection(togglers, function (e) {
    e.stopPropagation()
    toggleNavigation(e.currentTarget)
    e.preventDefault()
  })

  addClickEventToCollection(vertNavTogglers, function () {
    const shouldVertNavCollapse = !JSON.parse(store.isVerticalNavCollapsed || false)

    document.querySelector('.vertical-nav')
      .classList
      .toggle('collapsed')

    store.isVerticalNavCollapsed = shouldVertNavCollapse
  })
})
