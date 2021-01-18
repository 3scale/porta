import React from 'react'
import { StripeElementsForm } from 'PaymentGateways/components/StripeFormWrapper'
import { mount } from 'enzyme'

const props = {
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

it('should render properly', () => {
  const wrapper = mount(<StripeElementsForm { ...props } />)
  expect(wrapper).toMatchSnapshot()
  expect(wrapper.find('.StripeElementsForm').exists()).toEqual(true)
  expect(wrapper.find('#stripe-form').exists()).toEqual(true)
})

it('should disable submit button by default', () => {
  const wrapper = mount(<StripeElementsForm { ...props } />)
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(true)
})

// TODO: Update tests
// Testing @stripe/react-stripe-js is very tricky, in fact there are no official docs or examples
// Stripe team is working on that issue, see discussion in https://github.com/stripe/react-stripe-js/issues/59
// we should update this tests when the issue is updated
it.skip('should enable submit button when form is complete and valid', () => {
  const wrapper = mount(<StripeElementsForm { ...props } />)
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(true)
  wrapper.find('.CardNumberField-input-wrapper span input').simulate('change', { target: { value: '4111 1111 1111 1111' } })
  wrapper.find('.CardField-expiry span span .InputElement')
    .simulate('change', { target: { value: '11 / 22' } })
  wrapper.find('.CardField-cvc span span .InputElement')
    .simulate('change', { target: { value: '123' } })
  wrapper.find('.CardField-postalCode span span .InputElement')
    .simulate('change', { target: { value: '01234' } })
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(false)
})
