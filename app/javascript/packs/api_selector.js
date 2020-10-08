import { ContextSelectorWrapper } from 'Navigation/components/ContextSelector'

const containerId = 'api_selector'

document.addEventListener('DOMContentLoaded', function () {
  const apiSelector = document.getElementById(containerId)

  const { currentApi } = apiSelector.dataset

  ContextSelectorWrapper({
    ...apiSelector.dataset,
    currentApi: JSON.parse(currentApi)
  }, containerId)
})
