import {
  BraintreeFormWrapper,
  createBraintreeClient
} from 'PaymentGateways'
import client from 'braintree-web/client'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', async () => {
  const containerId = 'braintree-form-wrapper'
  const containerDataset = document.getElementById(containerId).dataset
  const clientToken = containerDataset.clientToken
  const braintreeClient = await createBraintreeClient(client, clientToken)
  const props = {
    braintreeClient,
    billingAddress: safeFromJsonString(containerDataset.billingAddress),
    threeDSecureEnabled: containerDataset.threeDSecureEnabled === 'true',
    formActionPath: containerDataset.formActionPath,
    countriesList: containerDataset.countriesList,
    selectedCountryCode: containerDataset.selectedCountryCode
  }

  BraintreeFormWrapper(props, containerId)
})
