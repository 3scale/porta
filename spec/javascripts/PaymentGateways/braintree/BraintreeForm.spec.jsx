import * as React from 'react'
import { act } from 'react-dom/test-utils'

import { BraintreeForm } from 'PaymentGateways'
import { mount } from 'enzyme'

const COUNTRIES_LIST = '[["Afghanistan","AF"],["Albania","AL"],["Algeria","DZ"],["Spain","ES"]]'

const props = {
  braintreeClient: {},
  billingAddress: {
    company: 'Kserol',
    address: '',
    address1: 'Napols 182',
    address2: '',
    phone_number: '1234567890',
    city: 'Barcelona',
    country: 'Spain',
    state: '',
    zip: '08013'
  },
  threeDSecureEnabled: true,
  formActionPath: 'form-path',
  countriesList: COUNTRIES_LIST,
  selectedCountryCode: 'ES'
}

// TODO: Investigate how to test Braintree
// Since braintree fields are injected dinamycally and are owned by a external script,
// we can't test them here, we can just test the form is displayed and disabled by default.

it('should render properly', () => {
  const wrapper = mount(<BraintreeForm {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it('should render submit button disabled by default', () => {
  const wrapper = mount(<BraintreeForm {...props} />)
  expect(wrapper.find('.btn-primary').prop('disabled')).toEqual(true)
})

it('should pre-fill billing address inputs when a value is provided', () => {
  const wrapper = mount(<BraintreeForm {...props} />)
  expect(wrapper.find('input#customer_credit_card_billing_address_company').props().value).toEqual('Kserol')
  expect(wrapper.find('input#customer_credit_card_billing_address_street_address').props().value).toEqual('Napols 182')
  expect(wrapper.find('input#customer_credit_card_billing_address_postal_code').props().value).toEqual('08013')
  expect(wrapper.find('input#customer_credit_card_billing_address_locality').props().value).toEqual('Barcelona')
  expect(wrapper.find('select#customer_credit_card_billing_address_country_name').props().value).toEqual('ES')
})

it('should enable submit button when form is valid', () => {
  // We can't access braintree card fields, mocking state to pass form vaidation
  const stateSetter = jest.fn()
  jest.spyOn(React, 'useState')
    .mockImplementationOnce(init => [null, stateSetter]) // hostedFieldsInstance
    .mockImplementationOnce(init => ['', stateSetter]) // braintreeNonceValue
    .mockImplementationOnce(init => [props.billingAddress, stateSetter]) // billingAddressData
    .mockImplementationOnce(init => [true, stateSetter]) // isCardValid
    .mockImplementationOnce(init => [null, stateSetter]) // formErrors
    .mockImplementationOnce(init => [null, stateSetter]) // cardError
    .mockImplementationOnce(init => [false, stateSetter]) // isLoading

  const wrapper = mount(<BraintreeForm {...props} />)
  act(() => {
    wrapper.find('input#customer_first_name').props().onChange({currentTarget: { value: 'Jane' }})
    wrapper.find('input#customer_last_name').props().onChange({currentTarget: { value: 'Doe' }})
    wrapper.find('input#customer_phone').props().onChange({currentTarget: { value: '1234567890' }})
  })

  expect(wrapper.find('.btn-primary').prop('disabled')).toEqual(false)
})
