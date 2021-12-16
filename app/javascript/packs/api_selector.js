import { ContextSelectorWrapper } from 'Navigation/components/ContextSelector'

const containerId = 'api_selector'

document.addEventListener('DOMContentLoaded', function () {
  const apiSelector = document.getElementById(containerId)

  ContextSelectorWrapper({
    ...apiSelector.dataset
  }, containerId)
})
