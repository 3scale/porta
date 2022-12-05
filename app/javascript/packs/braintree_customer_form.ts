import { client } from 'braintree-web'

import { createBraintreeClient } from 'PaymentGateways/braintree/braintree'
import { BraintreeFormWrapper } from 'PaymentGateways/braintree/BraintreeForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Client } from 'braintree-web'
import type { BillingAddressData } from 'PaymentGateways/braintree/types'

const CONTAINER_ID = 'braintree-form-wrapper'

// eslint-disable-next-line @typescript-eslint/no-misused-promises
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById(CONTAINER_ID)
  if (!container) {
    throw new Error('The target ID was not found: ' + CONTAINER_ID)
  }

  const { clientToken, threeDSecureEnabled, formActionPath, countriesList, selectedCountryCode } = container.dataset as Record<string, string>

  const billingAddress = safeFromJsonString<BillingAddressData>(container.dataset.billingAddress) ?? {}
  for (const key in billingAddress) {
    // @ts-expect-error FIXME
    if (billingAddress[key] === null) {
      // @ts-expect-error FIXME
      billingAddress[key] = ''
    }
  }
  const braintreeClient = await createBraintreeClient(client, clientToken) as Client

  BraintreeFormWrapper({
    braintreeClient,
    formActionPath: formActionPath,
    countriesList: countriesList,
    selectedCountryCode: selectedCountryCode,
    billingAddress,
    threeDSecureEnabled: threeDSecureEnabled === 'true'
  }, CONTAINER_ID)
})
