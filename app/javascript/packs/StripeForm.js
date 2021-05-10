import { StripeFormWrapper } from 'PaymentGateways'
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'stripe-form-wrapper'
  const containerDataset = document.getElementById(containerId).dataset

  StripeFormWrapper({
    stripePublishableKey: containerDataset.stripePublishableKey,
    setupIntentSecret: containerDataset.setupIntentSecret,
    billingAddressDetails: safeFromJsonString(containerDataset.billingAddress),
    successUrl: containerDataset.successUrl,
    isCreditCardStored: containerDataset.creditCardStored === 'true'
  }, containerId)
})
