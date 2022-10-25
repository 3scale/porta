import { PotentialUpgradesWidgetWrapper } from 'Dashboard/components/PotentialUpgradesWidget'
import { safeFromJsonString } from 'utilities'

const containerId = 'potential-upgrades-widget'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { violations, incorrectSetUp, links } = safeFromJsonString(container.dataset.potentialUpgradesWidget)

  PotentialUpgradesWidgetWrapper({
    violations,
    incorrectSetUp,
    links
  }, containerId)
})
