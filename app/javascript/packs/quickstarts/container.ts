import { QuickStartContainerWrapper as QuickStartContainer } from 'QuickStarts/components/QuickStartContainer'
import { getActiveQuickstart } from 'QuickStarts/utils/progressTracker'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'quick-start-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error(`Container not found: #${containerId}`)
  }

  const { links, renderCatalog } = container.dataset
  const parsedRenderCatalog = safeFromJsonString<boolean>(renderCatalog)
  const willRenderQuickStartContainer = getActiveQuickstart() ?? parsedRenderCatalog

  if (!willRenderQuickStartContainer) {
    container.remove()
    return
  }

  QuickStartContainer({
    links: safeFromJsonString<[string, string, string][]>(links) ?? [],
    renderCatalog: parsedRenderCatalog
  }, containerId)

  const wrapperContainer = document.getElementById('wrapper')
  const quickStartsContainer = document.querySelector('.pfext-quick-start-drawer__body')

  if (quickStartsContainer && wrapperContainer) {
    quickStartsContainer.after(wrapperContainer)
  }
})
