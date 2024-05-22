import { QuickStartContainerWrapper as QuickStartContainer } from 'QuickStarts/components/QuickStartContainer'
import { getActiveQuickstart } from 'QuickStarts/utils/progressTracker'
import { safeFromJsonString } from 'utilities/json-utils'

const renderQuickStarts = (): void => {
  const containerId = 'quick-start-container'
  const container = document.getElementById(containerId)

  // QuickStarts are hidden behind config QuickstartsConfig
  if (!container) {
    return
  }

  const { images, links, renderCatalog } = container.dataset
  const parsedRenderCatalog = safeFromJsonString<boolean>(renderCatalog)
  const willRenderQuickStartContainer = getActiveQuickstart() ?? parsedRenderCatalog

  if (!willRenderQuickStartContainer) {
    container.remove()
    return
  }

  QuickStartContainer({
    images: safeFromJsonString<Record<string, string>>(images) ?? {},
    links: safeFromJsonString<[string, string, string][]>(links) ?? [],
    renderCatalog: parsedRenderCatalog
  }, containerId)

  const wrapperContainer = document.getElementById('wrapper')
  const quickStartsContainer = document.querySelector('.pfext-quick-start-drawer__body')

  if (quickStartsContainer && wrapperContainer) {
    quickStartsContainer.after(wrapperContainer)
  }
}

export { renderQuickStarts }
