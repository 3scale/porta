import { IndexPageWrapper } from 'EmailConfigurations/components/IndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { EmailConfiguration } from 'EmailConfigurations/types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'email-configurations-index-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { dataset } = container

  const emailConfigurations = safeFromJsonString<EmailConfiguration[]>(dataset.emailConfigurations) || []
  const emailConfigurationsCount = safeFromJsonString<number>(dataset.emailConfigurationsCount) || 0
  const newEmailConfigurationPath = dataset.newEmailConfigurationPath || ''

  IndexPageWrapper({
    emailConfigurations,
    emailConfigurationsCount,
    newEmailConfigurationPath
  }, containerId)
})
