import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('th.backend_api_metric_title')
    .forEach(th => {
      const { collapsible, metrics } = th.dataset
      const ids = safeFromJsonString(metrics)

      if (collapsible) {
        const caret = document.createElement('i')
        caret.classList.add('fa', 'fa-caret-down')

        const span = th.querySelector('span')
        span.insertBefore(caret, span.firstChild)
        span.addEventListener('click', () => {
          th.classList.toggle('collapsed')
          ids.forEach(id => document.getElementById(`metric_${id}`).classList.toggle('hidden'))
        })
      }
    })
})
