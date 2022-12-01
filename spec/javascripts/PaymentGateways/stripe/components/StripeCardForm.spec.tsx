import React from 'react'
import { mount } from 'enzyme'

import { StripeCardForm } from 'PaymentGateways/stripe/components/StripeCardForm'

import type { Props } from 'PaymentGateways/stripe/components/StripeCardForm'

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

const mountWrapper = (props: Partial<Props> = {}) => mount((<StripeCardForm {...{ ...defaultProps, ...props }} />))

it('should have cardholder name input', () => {
  const wrapper = mountWrapper()
  const ccNameInput = wrapper.find('input#cardholder-name')
  expect(ccNameInput.at(0).props().placeholder).toEqual("Cardholder's name (optional)")
})
