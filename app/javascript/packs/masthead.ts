import { MastheadWrapper as Masthead } from 'Navigation/components/Masthead'

import type { Props } from 'Navigation/components/Masthead'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'header-container'
  const container = document.getElementById(containerId)

  if (!container?.dataset.props) {
    return
  }

  const props = JSON.parse(container.dataset.props) as Props

  Masthead({ ...props }, containerId)
})
