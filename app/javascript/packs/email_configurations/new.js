// @flow

import { NewPageWrapper } from 'EmailConfigurations/components/NewPage'
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
  // $FlowIgnore[incompatible-type] Safe to assume a model is always passed. See app/presenters/provider/admin/account/email_configurations_presenter.rb#new_data
  const emailConfiguration: FormEmailConfiguration = safeFromJsonString<FormEmailConfiguration>(dataset.emailConfiguration)
  const errors = safeFromJsonString<FormErrors>(dataset.errors)

  NewPageWrapper({
    url,
    emailConfiguration,
    errors
  }, containerId)
})
