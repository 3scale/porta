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

  const { clientToken, formActionPath, countriesList, selectedCountryCode, threeDSecureEnabled } = container.dataset as Record<string, string> // FIXME: We should not assume this attributes are present
  const billingAddress = {
    address: '',
    address1: '',
    address2: '',
    city: '',
    company: '',
    country: '',
    // eslint-disable-next-line @typescript-eslint/naming-convention
    phone_number: '',
    state: '',
    zip: '',
    ...safeFromJsonString<Partial<BillingAddressData>>(container.dataset.billingAddress)
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
