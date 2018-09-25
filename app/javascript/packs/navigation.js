import { toggleNavigation, hideAllToggleable } from '../src/Navigation/toggle_navigation'
import $ from 'jquery'

document.addEventListener('DOMContentLoaded', () => {
  window.$ = $
  window.toggleNavigation = toggleNavigation
  window.hideAllToggleable = hideAllToggleable
})
