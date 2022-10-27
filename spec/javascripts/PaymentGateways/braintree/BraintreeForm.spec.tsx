
import { BraintreeForm } from 'PaymentGateways/braintree/BraintreeForm'
import { mount } from 'enzyme'
import * as hostedFields from 'braintree-web/hosted-fields'
import * as validate from 'validate.js'

import type { Client } from 'braintree-web'
import type { Props } from 'PaymentGateways/braintree/BraintreeForm'

jest.mock('braintree-web/hosted-fields')
jest.spyOn(hostedFields, 'create').mockResolvedValue({
  getState: () => ({ fields: {} }),
  on: (event: string, fn: () => void) => {
    if (event === 'validityChange') {
      fn()
    }
  }
})

jest.mock('validate.js')

const COUNTRIES_LIST = '[["Afghanistan","AF"],["Albania","AL"],["Algeria","DZ"],["Spain","ES"]]'

const props: Props = {
  braintreeClient: {} as Client,
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

console.error = jest.fn()

// FIXME: Fix log error 'Warning: An update to BraintreeForm inside a test was not wrapped in act'
// Using 'act' or other solutions like 'runAllImmediates' does not seem to be valid solutions. Instead, the component BraintreeForm
// probably has to be refactored to reduce the number of async effects. Upgrading Enzyme to 3.10 is also irrelevant.
// Refs:
// - https://stackoverflow.com/q/55388587/5466997
// - https://github.com/eps1lon/react-act-immediate/blob/4d61b67dc98dd8dd422a41d07b82e08a8031bded/src/index.test.js
// - https://github.com/airbnb/enzyme/issues/2073
it('should enable submit button when form is valid', async () => {
  jest.spyOn(validate, 'validate')
    .mockReturnValueOnce(undefined)

  // eslint-disable-next-line @typescript-eslint/await-thenable
  const wrapper = await mount(<BraintreeForm {...props} />)
  wrapper.update()
  expect(wrapper.find('.btn-primary').prop('disabled')).toEqual(false)
})
