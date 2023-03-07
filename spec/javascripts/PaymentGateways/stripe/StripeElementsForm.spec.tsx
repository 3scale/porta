import { mount } from 'enzyme'

import { StripeElementsForm } from 'PaymentGateways/stripe/StripeElementsForm'

import type { Props } from 'PaymentGateways/stripe/StripeElementsForm'

const defaultProps: Props = {
  setupIntentSecret: 'efgh',
  billingAddressDetails: {
    line1: '1002 Avenue de los Mexicanos',
    line2: '',
    city: 'South Park',
    state: 'CO',
    postal_code: '80440',
    country: 'US'
  },
  billingName: 'Guy Random',
  successUrl: '/Broflovski/Residence',
  isCreditCardStored: false
}

it('should send billing address and name', () => {
  const wrapper = mount(<StripeElementsForm {...defaultProps} />)

  wrapper.find('button[type="submit"]').simulate('submit')
})
