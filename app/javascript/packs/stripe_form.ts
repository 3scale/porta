import { StripeFormWrapper } from 'PaymentGateways/stripe/StripeFormWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { StripeFormDataset } from 'PaymentGateways/stripe/types'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'stripe-form-wrapper'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const data = safeFromJsonString<StripeFormDataset>(container.dataset.stripeForm)

  if (!data) {
    throw new Error('Stripe data was not provided')
  }

  const { stripePublishableKey, setupIntentSecret, billingAddress, successUrl, creditCardStored } = data

  StripeFormWrapper({
    publishableKey: stripePublishableKey,
    setupIntentSecret,
    billingAddressDetails: billingAddress,
    successUrl,
    isCreditCardStored: creditCardStored
  }, containerId)
})
