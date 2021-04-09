import { BraintreeFormWrapper } from 'PaymentGateways'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'braintree-form-wrapper'
  const containerDataset = document.getElementById(containerId).dataset
  const props = {
    clientToken: containerDataset.clientToken,
    billingAddress: safeFromJsonString(containerDataset.billingAddress),
    threeDSecureEnabled: containerDataset.threeDSecureEnabled === 'true',
    formActionPath: containerDataset.formActionPath,
    countriesList: containerDataset.countriesList
  }

  BraintreeFormWrapper(props, containerId)
})
