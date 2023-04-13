import { renderContextSelector } from 'Navigation/renderContextSelector'
import { renderVerticalNav } from 'Navigation/renderVerticalNav'
import { setupHeaderTools } from 'Navigation/setupHeaderTools'
import { renderQuickStarts } from 'QuickStarts/renderQuickStarts'

document.addEventListener('DOMContentLoaded', () => {
  setupHeaderTools()
  renderVerticalNav()
  renderContextSelector()
  renderQuickStarts()
})
