import { toggleNavigation, hideAllToggleable } from '../src/Navigation/utils/toggle_navigation'
import { ContextSelectorWrapper } from '../src/Navigation/components/ContextSelector'

document.addEventListener('DOMContentLoaded', () => {
  window.toggleNavigation = toggleNavigation
  window.hideAllToggleable = hideAllToggleable
  window.ContextSelector = ContextSelectorWrapper
})
