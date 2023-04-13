import { ContextSelectorWrapper } from 'Navigation/components/ContextSelector'

import type { Menu } from 'Types/NavigationTypes'

const renderContextSelector = (): void => {
  const containerId = 'api_selector'

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Always present in header
  const apiSelector = document.getElementById(containerId)!

  const { activeMenu, audienceLink, settingsLink = '', productsLink = '', backendsLink = '' } = apiSelector.dataset

  ContextSelectorWrapper({
    activeMenu: activeMenu as Menu,
    audienceLink,
    settingsLink,
    productsLink,
    backendsLink
  }, containerId)
}

export { renderContextSelector }
