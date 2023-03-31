import { StripeFormWrapper } from 'PaymentGateways/stripe/StripeFormWrapper'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { BillingAddress } from 'PaymentGateways/stripe/types'

jest.mock('utilities/createReactWrapper', () => ({
  createReactWrapper: jest.fn()
}))

it('should create a react wrapper', () => {
  StripeFormWrapper({
    publishableKey: '',
    setupIntentSecret: '',
    billingAddressDetails: {} as BillingAddress,
    successUrl: '',
    isCreditCardStored: false
  }, 'some-id')

  expect(createReactWrapper).toHaveBeenCalledTimes(1)
  expect(createReactWrapper).toHaveBeenCalledWith(expect.anything(), 'some-id')
})
