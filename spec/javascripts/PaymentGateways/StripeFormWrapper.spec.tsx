
import { mount } from 'enzyme'

import { StripeElementsForm } from 'PaymentGateways/stripe/components/StripeFormWrapper'

import type { Props } from 'PaymentGateways/stripe/components/StripeFormWrapper'

const defaultProps: Props = {
  stripePublishableKey: 'abcd',
  setupIntentSecret: 'efgh',
  billingAddressDetails: {
    line1: '1002 Avenue de los Mexicanos',
    line2: '',
    city: 'South Park',
    state: 'CO',
    postal_code: '80440',
    country: 'US'
  },
  successUrl: '/Broflovski/Residence',
  isCreditCardStored: false
}

/**
* IMPORTANT NOTE:
* stripe-react is not easy to test, see discussion in https://github.com/stripe/react-stripe-js/issues/59
* we should update this tests when the issue is updated
*/

it('should render properly', () => {
  const wrapper = mount(<StripeElementsForm {...defaultProps} />)
  expect(wrapper.exists('.StripeElementsForm')).toEqual(true)
  expect(wrapper.exists('#stripe-form')).toEqual(true)
})

it('should enable submit button when form is complete and valid', () => {
  const wrapper = mount(<StripeElementsForm {...defaultProps} />)
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(true)

  // TODO: this should be possible without mocking the whole component
  // wrapper.find('CardElement').simulate('change', { complete: true })
  // wrapper.update()
  // expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(false)
})

describe('A credit card is stored', () => {
  const props = { ...defaultProps, isCreditCardStored: true }

  it('should render properly', () => {
    const wrapper = mount(<StripeElementsForm {...props} />)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toEqual(true)
  })
})

describe('No credit card is stored', () => {
  const props = { ...defaultProps, isCreditCardStored: false }

  it('should render properly', () => {
    const wrapper = mount(<StripeElementsForm {...props} />)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toEqual(false)
  })
})
