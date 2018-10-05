import { show as showBubble } from '../src/Onboarding/Bubble'
import { Bubble } from '../src/Onboarding/Bubble'

document.addEventListener('DOMContentLoaded', () => {
  window.Bubble = Bubble
  window.showBubble = showBubble
})
