import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  function toggleMetricVisibility (id) {
    document.getElementById(`metric_${id}`)
      .classList
      .toggle('hidden')
  }

  const ths = document.querySelectorAll('th.backend_api_metric_title')
  // NodeList.foreEach not supported in IE11
  for (const th of ths) {
    const { collapsible, metrics } = th.dataset
    const ids = safeFromJsonString(metrics)

    if (collapsible) {
      const toggleBackendAPI = () => {
        th.classList.toggle('collapsed')
        ids.forEach(toggleMetricVisibility)
      }

      const caret = document.createElement('i')
      // Multiple arguments for 'add' not supported in IE11
      caret.classList.add('fa')
      caret.classList.add('fa-caret-down')

      const span = th.querySelector('span')
      span.insertBefore(caret, span.firstChild)
      span.addEventListener('click', toggleBackendAPI)

      // First render with all metrics collapsed
      toggleBackendAPI()
    }
  }
})
