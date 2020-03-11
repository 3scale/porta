import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  function toggleMetricVisibility (id) {
    document.getElementById(`metric_${id}`)
      .classList
      .toggle('hidden')
  }

  const ths = document.querySelectorAll('th.backend_api_metric_title')
  ths.forEach(
    (th) => {
      const { collapsible, metrics } = th.dataset
      const ids = safeFromJsonString(metrics)

      if (collapsible) {
        th.classList.add('collapsible')

        const toggleBackendAPI = () => {
          th.classList.toggle('collapsed')
          ids.forEach(toggleMetricVisibility)
        }

        const caret = document.createElement('i')
        caret.classList.add('fa', 'fa-caret-down')

        const span = th.querySelector('span')
        span.insertBefore(caret, span.firstChild)
        span.addEventListener('click', toggleBackendAPI)

        // First render with all metrics collapsed
        toggleBackendAPI()
      }
    }
  )
})
