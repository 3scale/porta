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
    stripePublishableKey: containerDataset.stripePublishableKey ?? '',
    setupIntentSecret: containerDataset.setupIntentSecret ?? '',
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: we can assume it's there, but that doesn't make it right
    billingAddressDetails: safeFromJsonString<Props['billingAddressDetails']>(containerDataset.billingAddress)!,
    successUrl: containerDataset.successUrl ?? '',
    isCreditCardStored: containerDataset.creditCardStored === 'true'
  }, containerId)
})
