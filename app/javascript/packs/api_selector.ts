import { ContextSelectorWrapper } from 'Navigation/components/ContextSelector'

import type { Menu } from 'Types/NavigationTypes'

const containerId = 'api_selector'

document.addEventListener('DOMContentLoaded', function () {
  const apiSelector = document.getElementById(containerId)

  if (!apiSelector) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { activeMenu, audienceLink, settingsLink = '', productsLink = '', backendsLink = '' } = apiSelector.dataset

  ContextSelectorWrapper({
    activeMenu: activeMenu as Menu,
    audienceLink,
    settingsLink,
    productsLink,
    backendsLink
  }, containerId)
})
