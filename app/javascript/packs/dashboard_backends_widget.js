import { BackendsWidgetWrapper } from 'Dashboard/components/BackendsWidget'
import { safeFromJsonString } from 'utilities'

const containerId = 'backends-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  const { newBackendPath, backendsPath, backends } = safeFromJsonString(container.dataset.backendsWidget)

  BackendsWidgetWrapper({
    newBackendPath,
    backendsPath,
    backends
  }, containerId)
})
