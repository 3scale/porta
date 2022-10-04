import { BraintreeFormWrapper, createBraintreeClient } from 'PaymentGateways'
import { client } from 'braintree-web'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Client } from 'braintree-web'
import type { BillingAddressData } from 'PaymentGateways'

const CONTAINER_ID = 'braintree-form-wrapper'

document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById(CONTAINER_ID)
  if (!container) {
    return
  }

  const { clientToken, threeDSecureEnabled, formActionPath, countriesList, selectedCountryCode } = container.dataset as Record<string, string>
  const billingAddress = safeFromJsonString<BillingAddressData>(container.dataset.billingAddress) as BillingAddressData
  for (const key in billingAddress) {
    if (billingAddress[key as keyof BillingAddressData] === null) {
      billingAddress[key as keyof BillingAddressData] = ''
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
