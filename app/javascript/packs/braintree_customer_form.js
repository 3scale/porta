import {
  BraintreeFormWrapper,
  createBraintreeClient
} from 'PaymentGateways'
import client from 'braintree-web/client'
import { safeFromJsonString } from 'utilities/json-utils'

const CONTAINER_ID = 'braintree-form-wrapper'

document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById(CONTAINER_ID)
  if (!container) {
    return
  }

  const { clientToken, billingAddress, threeDSecureEnabled, formActionPath, countriesList, selectedCountryCode } = container.dataset
  const billingAddressParsed = safeFromJsonString(billingAddress) || {}
  for (let key in billingAddressParsed) {
    if (billingAddressParsed[key] === null) {
      billingAddressParsed[key] = ''
    }
  }
  const braintreeClient = await createBraintreeClient(client, clientToken)

  const props = {
    braintreeClient,
    formActionPath,
    countriesList,
    selectedCountryCode,
    billingAddress: billingAddressParsed,
    threeDSecureEnabled: threeDSecureEnabled === 'true'
  }

  BraintreeFormWrapper(props, CONTAINER_ID)
})
