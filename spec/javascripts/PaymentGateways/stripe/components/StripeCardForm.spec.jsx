// @flow

import React from 'react'
import { StripeCardForm } from 'PaymentGateways/stripe/components/StripeCardForm'
import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'
import { mount } from 'enzyme'

const defaultProps = {
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

// NOTE: we wrap  StripeCardForm with Stripe's Elements, because of the following error otherwise:
// "Could not find Elements context; You need to wrap the part of your app that calls useStripe() in an <Elements> provider."
it('should have cardholder name input', () => {
  const wrapper = mount(<Elements stripe={loadStripe('fake-key')}><StripeCardForm {...defaultProps} /></Elements>)
  const ccNameInput = wrapper.find('input#cardholder-name')
  expect(ccNameInput.at(0).props().placeholder).toEqual("Cardholder's name (optional)")
})
