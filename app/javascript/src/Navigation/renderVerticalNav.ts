import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'
import { safeFromJsonString } from 'utilities/json-utils'

const renderVerticalNav = (): void => {
  const containerId = 'vertical-nav-wrapper'
  const container = document.getElementById(containerId)

  // Some pages don't feature the vertical nav
  if (!container) {
    return
  }

  const { activeItem, activeSection, currentApi, sections } = container.dataset

  VerticalNav({
    sections: safeFromJsonString(sections) ?? [],
    activeSection,
    activeItem,
    currentApi: safeFromJsonString(currentApi)
  }, containerId)
}

export { renderVerticalNav }
