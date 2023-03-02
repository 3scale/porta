import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { BraintreeForm } from 'PaymentGateways/braintree/BraintreeForm'
import * as useBraintreeHostedFields from 'PaymentGateways/braintree/utils/useBraintreeHostedFields'
import * as formValidation from 'PaymentGateways/braintree/utils/formValidation'
import { waitForPromises } from 'utilities/test-utils'

import type { FormEvent } from 'react'
import type { BraintreeError } from 'braintree-web'
import type { Props } from 'PaymentGateways/braintree/BraintreeForm'
import type { CustomHostedFields } from 'PaymentGateways/braintree/utils/useBraintreeHostedFields'

jest.mock('validate.js')

const COUNTRIES_LIST = [['Afghanistan', 'AF'], ['Albania', 'AL'], ['Algeria', 'DZ'], ['Spain', 'ES']] as [string, string][]

const selectors = {
  address: 'input[name="customer[credit_card][billing_address][street_address]"]',
  city: 'input[name="customer[credit_card][billing_address][locality]"]',
  company: 'input[name="customer[credit_card][billing_address][company]"]',
  country: 'select[name="customer[credit_card][billing_address][country_name]"]',
  firstName: 'input[name="customer[first_name]"]',
  lastName: 'input[name="customer[last_name]"]',
  phone: 'input[name="customer[phone]"]',
  state: 'input[name="customer[credit_card][billing_address][region]"]',
  zip: 'input[name="customer[credit_card][billing_address][postal_code]"]'
}

const defaultProps: Props = {
  clientToken: '',
  billingAddress: {
    address: '',
    city: '',
    country: '',
    countryCode: '',
    firstName: '',
    lastName: '',
    company: '',
    phone: '',
    state: '',
    zip: ''
  },
  threeDSecureEnabled: false,
  formActionPath: '',
  countriesList: COUNTRIES_LIST
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<BraintreeForm {...{ ...defaultProps, ...props }} />)

const hostedFields = { getNonce: jest.fn() } as unknown as CustomHostedFields
const mockHostedFields = (args: ReturnType<typeof useBraintreeHostedFields.useBraintreeHostedFields>) => {
  jest.spyOn(useBraintreeHostedFields, 'useBraintreeHostedFields').mockImplementation(() => args)
}

afterEach(() => {
  jest.restoreAllMocks()
})

describe('before instantiating hosted fields', () => {
  beforeEach(() => {
    mockHostedFields([undefined, undefined, true, false])
  })

  it('should render submit button disabled', () => {
    const wrapper = mountWrapper()

    expect(wrapper.find('button[type="submit"]').props().disabled).toBeTruthy()
  })

  it('should support default values', () => {
    const billingAddress = {
      firstName: 'Pepe',
      lastName: 'Pepez',
      phone: '555',
      address: '123 Fake Street',
      city: 'Springfield',
      company: 'Illegal Fireworks Co.',
      state: '',
      country: 'United States',
      countryCode: 'US',
      zip: '80085'
    }

    const wrapper = mountWrapper({ billingAddress })

    Object.keys(selectors).forEach((k) => {
      expect(wrapper.find(selectors[k as keyof typeof selectors]).props().value).toEqual(billingAddress[k as keyof typeof selectors])
    })
  })

  it('should render the countries list properly', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('[name="customer[credit_card][billing_address][country_name]"] option').map((n) => n.html()))
      .toMatchInlineSnapshot(`
        Array [
          "<option disabled=\\"\\" value=\\"\\"></option>",
          "<option>Afghanistan</option>",
          "<option>Albania</option>",
          "<option>Algeria</option>",
          "<option>Spain</option>",
        ]
      `)
  })

  it('should disable submit button even if form is valid', () => {
    jest.spyOn(formValidation, 'validateForm').mockReturnValue(undefined)
    const wrapper = mountWrapper()
    expect(wrapper.find('button[type="submit"]').props().disabled).toBeTruthy()
  })

  it('should disable credit card fields', () => {
    const wrapper = mountWrapper()

    const fieldset = wrapper.find('fieldset').at(1)
    expect(fieldset.containsMatchingElement(<legend>Credit Card</legend>)).toEqual(true)
    expect(fieldset.props().disabled).toBeTruthy()
  })
})

describe('when hosted fields fail to instantiate', () => {
  beforeEach(() => {
    const error = { message: 'Error!' } as BraintreeError
    mockHostedFields([undefined, error, false, false])

    jest.spyOn(console, 'error').mockImplementation() // Silence console.error for this block
  })

  it('should disable the submit button', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('button[type="submit"]').props().disabled).toBeTruthy()
  })
})

describe('after hosted fields instantiated', () => {
  describe('and hosted fields are valid', () => {
    beforeEach(() => {
      jest.spyOn(hostedFields, 'getNonce').mockResolvedValue('nonce')
      mockHostedFields([hostedFields, undefined, false, true])
    })

    it('should disable submit button if billing address incorrect', () => {
      jest.spyOn(formValidation, 'validateForm').mockReturnValueOnce({})
      expect(mountWrapper().find('button[type="submit"]').props().disabled).toBeTruthy()
    })

    describe('and billing address is valid', () => {
      beforeEach(() => {
        jest.spyOn(formValidation, 'validateForm').mockReturnValueOnce(undefined)
      })

      it('should enable submit button', () => {
        const wrapper = mountWrapper()
        expect(wrapper.find('button[type="submit"]').props().disabled).toBeFalsy()
      })

      it.todo('should set the nonce before submitting')

      it('should disable submit button while submitting', async () => {
        const submit = jest.spyOn(HTMLFormElement.prototype, 'submit')
        submit.mockImplementation(jest.fn())

        const wrapper = mountWrapper()
        expect(wrapper.find('button[type="submit"]').props().disabled).toBeFalsy()

        wrapper.find('button[type="submit"]').simulate('submit')
        expect(wrapper.find('button[type="submit"]').props().disabled).toBeTruthy()

        await waitForPromises(wrapper)
        expect(submit).toHaveBeenCalledTimes(1)
      })

      it('should send all the fields for card verification', async () => {
        jest.spyOn(HTMLFormElement.prototype, 'submit').mockImplementation(jest.fn())

        const billingAddress = {
          firstName: 'Pepe',
          lastName: 'Pepez',
          phone: '555',
          address: '123 Fake Street',
          city: 'Springfield',
          company: 'Illegal Fireworks Co.',
          state: '',
          zip: '80085'
        }

        const getNonce = jest.spyOn(hostedFields, 'getNonce')
        mockHostedFields([hostedFields, undefined, false, true])

        const wrapper = mountWrapper()

        act(() => {
          for (const key in billingAddress) {
            // @ts-expect-error Fuck
            // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
            wrapper.find(selectors[key]).props().onChange!({ currentTarget: { value: billingAddress[key] } })
          }

          // IMPORTANT NOTE: select has a first empty option, so selectedIndex is +1 compared to countriesList
          wrapper.find('select').props().onChange!({ currentTarget: { value: 'Spain', selectedIndex: 4 } as unknown as EventTarget } as FormEvent)
        })

        wrapper.find('button[type="submit"]').simulate('submit')

        expect(getNonce).toHaveBeenCalledWith(expect.objectContaining({ ...billingAddress, countryCode: 'ES' }))

        await waitForPromises(wrapper)
      })
    })

    describe('but card verification fails', () => {
      it('should show an inline error after submitting', async () => {
        const message = 'An error occurred, please review your CC details or try later.'
        jest.spyOn(hostedFields, 'getNonce').mockRejectedValue({ message })
        mockHostedFields([hostedFields, undefined, false, true])
        jest.spyOn(console, 'error').mockImplementation(jest.fn())

        const wrapper = mountWrapper()
        wrapper.find('button[type="submit"]').simulate('submit')
        expect(wrapper.exists('.alert.alert-danger')).toEqual(false)

        await waitForPromises(wrapper)
        expect(wrapper.find('.alert.alert-danger').text()).toEqual(message)
      })
    })
  })

  describe('and hosted fields are invalid', () => {
    beforeEach(() => {
      jest.spyOn(hostedFields, 'getNonce').mockResolvedValue('nonce')
      mockHostedFields([hostedFields, undefined, false, false])
    })

    it('should disable submit button regardless of billing address', () => {
      jest.spyOn(formValidation, 'validateForm').mockReturnValueOnce(undefined)
      expect(mountWrapper().find('button[type="submit"]').props().disabled).toBeTruthy()
    })
  })
})
