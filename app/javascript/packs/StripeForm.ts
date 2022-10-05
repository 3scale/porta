import { StripeFormWrapper } from 'PaymentGateways/stripe/components/StripeFormWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'PaymentGateways/stripe/components/StripeFormWrapper'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'stripe-form-wrapper'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const containerDataset = container.dataset

  StripeFormWrapper({
    stripePublishableKey: containerDataset.stripePublishableKey || '',
    setupIntentSecret: containerDataset.setupIntentSecret || '',
    billingAddressDetails: safeFromJsonString(containerDataset.billingAddress) as Props['billingAddressDetails'],
    successUrl: containerDataset.successUrl || '',
    isCreditCardStored: containerDataset.creditCardStored === 'true'
  }, containerId)
})
