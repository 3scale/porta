import { toggleNavigation, hideAllToggleable } from 'Navigation/utils/toggle_navigation'
import { ContextSelectorWrapper } from 'Navigation/components/ContextSelector'

document.addEventListener('DOMContentLoaded', () => {
  window.toggleNavigation = toggleNavigation
  window.hideAllToggleable = hideAllToggleable
  window.ContextSelector = ContextSelectorWrapper
})
