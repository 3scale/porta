// @flow

import { widget } from 'Dashboard'

export function loadAudienceWidget (widgetPath: string) {
  widget(widgetPath)
}

export function loadServiceWidget (serviceId: string, widgetPath: string) {
  const container = document.getElementById(`service_${serviceId}`)
  if (!container) {
    return
  }

  const toggleableTitle = container.querySelector('.DashboardSection-toggle')

  if (!toggleableTitle) {
    widget(widgetPath)
    return
  }

  let value = window.localStorage[`toggle:service_${serviceId}`]
  if (value && !JSON.parse(value)['is-closed']) {
    widget(widgetPath)
    return
  }

  toggleableTitle.addEventListener('click', () => {
    const isCurrentlyClosed = container.classList.contains('is-closed')
    if (isCurrentlyClosed) {
      widget(widgetPath)
    }
  })
}
