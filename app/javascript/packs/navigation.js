import { toggleNavigation, hideAllToggleable } from '../src/Navigation/toggle_navigation'
import { ApiSelector } from '../src/Navigation/api_selector'
import $ from 'jquery'

document.addEventListener('DOMContentLoaded', () => {
  window.$ = $
  window.toggleNavigation = toggleNavigation
  window.hideAllToggleable = hideAllToggleable
  window.ApiSelector = ApiSelector
})
