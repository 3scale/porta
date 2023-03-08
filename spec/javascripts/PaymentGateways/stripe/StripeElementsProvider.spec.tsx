import { mount } from 'enzyme'

import { StripeElementsProvider } from 'PaymentGateways/stripe/StripeElementsProvider'

it('should render', () => {
  const wrapper = mount(<StripeElementsProvider publishableKey="public-key" />)
  expect(wrapper.exists()).toEqual(true)
})
