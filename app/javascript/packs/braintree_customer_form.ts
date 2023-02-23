import { BraintreeFormWrapper } from 'PaymentGateways/braintree/BraintreeForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { BraintreeFormDataset } from 'PaymentGateways/braintree/types'

const CONTAINER_ID = 'braintree-form-wrapper'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById(CONTAINER_ID)

  if (!container) {
    throw new Error('The target ID was not found: ' + CONTAINER_ID)
  }

  const data = safeFromJsonString<BraintreeFormDataset>(container.dataset.braintreeForm)

  if (!data) {
    throw new Error('Braintree data was not provided')
  }

  const { billingAddress, clientToken, countriesList, formActionPath, threeDSecureEnabled } = data

  BraintreeFormWrapper({
    billingAddress,
    clientToken,
    countriesList,
    formActionPath,
    threeDSecureEnabled
  }, CONTAINER_ID)
})
