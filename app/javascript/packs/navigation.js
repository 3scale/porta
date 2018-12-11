import { toggleNavigation, hideAllToggleable } from '../src/Navigation/utils/toggle_navigation'
import { ContextSelectorWrapper } from '../src/Navigation/components/ContextSelector'

import $ from 'jquery'

document.addEventListener('DOMContentLoaded', () => {
  window.ContextSelector = ContextSelectorWrapper
  let store = window.localStorage
  $(document)
    .on('click', '.u-toggler', function (e) {
      e.stopPropagation()
      toggleNavigation(e.currentTarget)
      e.preventDefault()
    })
    .on('click', 'body', function (e) {
      if (e.target.type !== 'search') {
        hideAllToggleable()
      }
    })
    .on('click', '.vert-nav-toggle', function () {
      const shouldVertNavCollapse = !JSON.parse(store.isVerticalNavCollapsed || false)
      $('.vertical-nav').toggleClass('collapsed', shouldVertNavCollapse)
      store.isVerticalNavCollapsed = shouldVertNavCollapse
    })
})
