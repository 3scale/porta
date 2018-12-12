import { show as showBubble } from 'Onboarding/Bubble'
import { Bubble } from 'Onboarding/Bubble'

document.addEventListener('DOMContentLoaded', () => {
  window.Bubble = Bubble
  window.showBubble = showBubble
})
