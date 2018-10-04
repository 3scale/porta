import { toggleNavigation, hideAllToggleable } from '../src/Navigation/toggle_navigation'
import { ApiSelector } from '../src/Navigation/api_selector'

document.addEventListener('DOMContentLoaded', () => {
  window.toggleNavigation = toggleNavigation
  window.hideAllToggleable = hideAllToggleable
  window.ApiSelector = ApiSelector
})
