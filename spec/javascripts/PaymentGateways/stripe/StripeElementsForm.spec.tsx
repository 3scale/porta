import { mount } from 'enzyme'
import { CardElement, useStripe } from '@stripe/react-stripe-js'
import { act } from 'react-dom/test-utils'
import * as ReactStripeJS from '@stripe/react-stripe-js'

import { StripeElementsForm } from 'PaymentGateways/stripe/StripeElementsForm'
import { waitForPromises } from 'utilities/test-utils'

import type { ReactWrapper } from 'enzyme'
import type { Stripe, StripeCardElementChangeEvent } from '@stripe/stripe-js'
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

const mountWrapper = (props: Partial<Props> = {}) => mount(<StripeElementsForm {...{ ...defaultProps, ...props }} />)

const addValidCreditCard = (wrapper: ReactWrapper<unknown>) => {
  act(() => {
    const event = { complete: true, error: undefined } as StripeCardElementChangeEvent
    // Ideally, we'd use simulate('change', { complete: true }) but CardElement is mocked.
    wrapper.find(CardElement).prop('onChange')!(event)
  })
}

const isSubmitDisabled = (wrapper: ReactWrapper<unknown>) => {
  return Boolean(wrapper.find('button[type="submit"]').props().disabled)
}

describe('when credit card is stored', () => {
  const props = { ...defaultProps, isCreditCardStored: true }

  it('should hide then card widget', () => {
    const wrapper = mountWrapper(props)

    const button = wrapper.find('.editCardButton')
    expect(button.text()).toEqual('Edit Credit Card Details')
    expect(wrapper.exists('.editCardButton i.fa-pencil')).toEqual(true)
    expect(wrapper.exists('#stripe-form.hidden')).toEqual(true)

    button.simulate('click')
    expect(wrapper.find('.editCardButton').text()).toEqual('cancel')
    expect(wrapper.exists('.editCardButton i.fa-chevron-left')).toEqual(true)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toEqual(false)
  })
})

describe('when credit card is not stored', () => {
  const props = { ...defaultProps, isCreditCardStored: false }

  it('should hide then card widget', () => {
    const wrapper = mountWrapper(props)

    const button = wrapper.find('.editCardButton')
    expect(button.text()).toEqual('cancel')
    expect(wrapper.exists('.editCardButton i.fa-chevron-left')).toEqual(true)
    expect(wrapper.find('#stripe-form').hasClass('hidden')).toEqual(false)

    button.simulate('click')
    expect(wrapper.find('.editCardButton').text()).toEqual('Edit Credit Card Details')
    expect(wrapper.exists('.editCardButton i.fa-pencil')).toEqual(true)
    expect(wrapper.exists('#stripe-form.hidden')).toEqual(true)
  })
})

describe('when confirmCardSetup returns an error', () => {
  beforeAll(() => {
    jest.spyOn(ReactStripeJS, 'useStripe')
      .mockImplementation(() => ({
        confirmCardSetup: () => Promise.resolve({
          error: { message: 'Something went wrong' },
          setupIntent: undefined
        })
      } as unknown as Stripe))
  })

  afterAll(() => {
    jest.resetAllMocks()
  })

  it('should render the error', async () => {
    const wrapper = mountWrapper()

    addValidCreditCard(wrapper)
    wrapper.find('button[type="submit"]').simulate('submit')
    await waitForPromises(wrapper)

    expect(wrapper.find('.cardErrors').text()).toEqual('Something went wrong')
  })

  it('should disable the submit button when form incomplete or submitting', async () => {
    const wrapper = mountWrapper()
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    addValidCreditCard(wrapper)
    expect(isSubmitDisabled(wrapper.update())).toEqual(false)

    wrapper.find('button[type="submit"]').simulate('submit')
    expect(isSubmitDisabled(wrapper.update())).toEqual(true)

    await waitForPromises(wrapper)
    expect(isSubmitDisabled(wrapper.update())).toEqual(false)
  })
})

describe('when confirmCardSetup is successfull', () => {
  beforeAll(() => {
    // Defined separately as a mock fn so that it can be checked later
    const confirmCardSetup = jest.fn(() => Promise.resolve({
      error: undefined,
      setupIntent: { status: 'succeeded' }
    }))

    jest.spyOn(ReactStripeJS, 'useStripe')
      .mockImplementation(() => ({ confirmCardSetup } as unknown as Stripe))
  })

  afterAll(() => {
    jest.restoreAllMocks()
  })

  it('should submit the form', async () => {
    const submit = jest.spyOn(HTMLFormElement.prototype, 'submit')
    const wrapper = mountWrapper()

    addValidCreditCard(wrapper)

    wrapper.find('button[type="submit"]').simulate('submit')

    await waitForPromises(wrapper)
    expect(submit).toHaveBeenCalledTimes(1)
  })

  it('should confirm card setup with billing address and name', () => {
    const wrapper = mountWrapper()

    addValidCreditCard(wrapper)

    wrapper.find('button[type="submit"]').simulate('submit')

    // eslint-disable-next-line jest/unbound-method -- Get the mock defined in __mocks__/@stripe/react-stripe-js.js
    const { confirmCardSetup } = useStripe()!
    expect(confirmCardSetup).toHaveBeenCalledTimes(1)
    expect(confirmCardSetup).toHaveBeenCalledWith(defaultProps.setupIntentSecret, {
      payment_method: expect.objectContaining({
        billing_details: expect.objectContaining({
          address: defaultProps.billingAddressDetails,
          name: defaultProps.billingName
        })
      })
    })
  })

  it.todo('should set stripe_payment_method_id value')
})

it('should not render an error by default', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.cardErrors')).toEqual(false)
})

it('should submit to the success url', () => {
  const successUrl = '/foo'
  const wrapper = mountWrapper({ successUrl })
  expect(wrapper.find('form#stripe-form').props().action).toEqual(successUrl)
})
