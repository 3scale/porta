import { client } from 'braintree-web'

import { createBraintreeClient } from 'PaymentGateways/braintree/braintree'
import { BraintreeFormWrapper } from 'PaymentGateways/braintree/BraintreeForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Client } from 'braintree-web'
import type { BraintreeFormDataset } from 'PaymentGateways/braintree/types'

const CONTAINER_ID = 'braintree-form-wrapper'

// eslint-disable-next-line @typescript-eslint/no-misused-promises
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById(CONTAINER_ID)
  if (!container) {
    throw new Error('The target ID was not found: ' + CONTAINER_ID)
  }

  const data = safeFromJsonString<BraintreeFormDataset>(container.dataset.braintreeForm)

  if (!data) {
    throw new Error('Braintree data was not provided')
  }
  const { billingAddress, clientToken, countriesList, formActionPath, threeDSecureEnabled, selectedCountryCode } = data

  const braintreeClient = await createBraintreeClient(client, clientToken) as Client

  BraintreeFormWrapper({
    braintreeClient,
    formActionPath: formActionPath,
    countriesList: countriesList,
    selectedCountryCode,
    billingAddress,
    threeDSecureEnabled
  }, CONTAINER_ID)
})
