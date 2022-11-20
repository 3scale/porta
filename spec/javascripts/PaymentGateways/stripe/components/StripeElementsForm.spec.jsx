import React from 'react'
import { act } from 'react-dom/test-utils'
import { CardElement } from '@stripe/react-stripe-js'
import { mount } from 'enzyme'

import { StripeElementsForm } from 'PaymentGateways/stripe/components/StripeFormWrapper'

import type { Props } from 'PaymentGateways/stripe/components/StripeFormWrapper'

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

const mountWrapper = (props: $Shape<Props> = {}) => mount(<StripeElementsForm { ...{ ...defaultProps, ...props } } />)

it('should render properly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(StripeElementsForm)).toEqual(true)
  expect(wrapper.exists('#stripe-form')).toEqual(true)
})

it('should enable submit button when form is complete and valid', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(true)

  act(() => { wrapper.find(CardElement).props().onChange({ complete: true }) })
  wrapper.update()
  expect(wrapper.find('#stripe-submit').prop('disabled')).toEqual(false)
})

describe('A credit card is stored', () => {
  const props = { isCreditCardStored: true }

  it('should render properly', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toBe(true)
  })
})

describe('No credit card is stored', () => {
  const props = { isCreditCardStored: false }

  it('should render properly', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toBe(false)
  })
})
