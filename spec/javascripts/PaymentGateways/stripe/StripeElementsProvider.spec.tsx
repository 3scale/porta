import { mount } from 'enzyme'
import { loadStripe } from '@stripe/stripe-js'

import { StripeElementsProvider } from 'PaymentGateways/stripe/StripeElementsProvider'

it('should load stripe with the provided key', () => {
  const publishableKey = 'public-key'
  mount(<StripeElementsProvider publishableKey={publishableKey} />)

  expect(loadStripe).toHaveBeenCalledWith(publishableKey)
  expect(loadStripe).toHaveBeenCalledTimes(1)
})
