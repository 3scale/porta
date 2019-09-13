// @flow

import { widget as makeWidgetRequest } from 'Dashboard'

export function loadAudienceWidget (widgetPath: string) {
  makeWidgetRequest(widgetPath)
}

export function loadServiceWidget (serviceId: string, widgetPath: string) {
  const container = document.getElementById(`service_${serviceId}`)
  if (!container) {
    return
  }

  const toggleableTitle = container.querySelector('.DashboardSection-toggle')

  if (!toggleableTitle) {
    makeWidgetRequest(widgetPath)
    return
  }

  let value = window.localStorage[`toggle:service_${serviceId}`]
  if (value && !JSON.parse(value)['is-closed']) {
    makeWidgetRequest(widgetPath)
    return
  }

  toggleableTitle.addEventListener('click', () => {
    const isCurrentlyClosed = container.classList.contains('is-closed')
    if (isCurrentlyClosed) {
      makeWidgetRequest(widgetPath)
    }
  })
}
