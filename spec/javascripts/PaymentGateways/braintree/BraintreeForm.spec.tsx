import { mount } from 'enzyme'
import * as validate from 'validate.js'

import { BraintreeForm } from 'PaymentGateways/braintree/BraintreeForm'
import { waitForPromises } from 'utilities/test-utils'
import * as braintree from 'PaymentGateways/braintree/braintree'

import type { Client } from 'braintree-web'
import type { Props } from 'PaymentGateways/braintree/BraintreeForm'

jest.mock('braintree-web/hosted-fields', () => ({
  create: () => new Promise(jest.fn()) // Unresolved promise
}))
jest.mock('validate.js')

const COUNTRIES_LIST: [string, string][] = [['Afghanistan', 'AF'], ['Albania', 'AL'], ['Algeria', 'DZ'], ['Spain', 'ES']]

const props: Props = {
  braintreeClient: {} as Client,
  billingAddress: {
    company: 'Kserol',
    address: 'Napols 182',
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

it('should render properly', () => {
  const wrapper = mount(<BraintreeForm {...props} />)
  expect(wrapper.exists()).toEqual(true)
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

it('should enable submit button when form is valid', async () => {
  jest.spyOn(validate, 'validate')
    .mockReturnValueOnce(undefined)

  jest.spyOn(braintree, 'createHostedFieldsInstance')
    .mockImplementationOnce((_hf, _client, _opts, setIsCardValid) => {
      setIsCardValid(true)

      return Promise.resolve({ tokenize: jest.fn() })
    })

  const wrapper = mount(<BraintreeForm {...props} />)

  await waitForPromises(wrapper)
  expect(wrapper.find('button[type="submit"]').props().disabled).toBeFalsy()
})
