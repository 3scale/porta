import {StripeFormWrapper} from 'PaymentGateways/components/StripeFormWrapper'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'stripe-form-wrapper'
  const containerDataset = document.getElementById(containerId).dataset

  StripeFormWrapper({
    stripePublishableKey: containerDataset.stripe_publishable_key,
    setupIntentSecret: containerDataset.setup_intent_secret,
    billingAddressDetails: safeFromJsonString(containerDataset.billing_address),
    successUrl: containerDataset.success_url,
    isCreditCardStored: (containerDataset.credit_card_stored === 'true')
  }, containerId)
})
