import {NewPageWrapper} from 'EmailConfigurations/components/NewPage';
import { safeFromJsonString } from 'utilities/json-utils'

import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'email-configurations-new-container'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  const { dataset } = container
  const { url } = dataset
  const emailConfiguration = safeFromJsonString<FormEmailConfiguration>(dataset.emailConfiguration)

  if (!emailConfiguration) {
    throw new Error('missing email_configuration')
  }

  const errors = safeFromJsonString<FormErrors>(dataset.errors)

  NewPageWrapper({
    url,
    emailConfiguration,
    errors
  }, containerId)
})
