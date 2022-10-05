import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'vertical-nav-wrapper'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { activeItem, activeSection, currentApi, sections } = container.dataset

  VerticalNav({
    sections: safeFromJsonString(sections) || [],
    activeSection,
    activeItem,
    currentApi: safeFromJsonString(currentApi)
  }, containerId)
})
