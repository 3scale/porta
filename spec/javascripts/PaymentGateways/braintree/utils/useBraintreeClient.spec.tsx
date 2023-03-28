import { mount } from 'enzyme'

import { useBraintreeHostedFields } from 'PaymentGateways/braintree/utils/useBraintreeHostedFields'
import { waitForPromises } from 'utilities/test-utils'
import * as createHostedFields from 'PaymentGateways/braintree/utils/createHostedFields'

import type { BillingAddress } from 'PaymentGateways/braintree/types'
import type { CustomHostedFields } from 'PaymentGateways/braintree/utils/useBraintreeHostedFields'
import type { HostedFields } from 'braintree-web/modules/hosted-fields'
import type { FunctionComponent } from 'react'

interface Props {
  setHostedFields?: (hostedFields?: CustomHostedFields) => void;
  setError?: (error: unknown) => void;
  setLoading?: (loading: boolean) => void;
  setCardValid?: (valid: boolean) => void;
  threeDSecureEnabled?: boolean;
}

const TestComponent: FunctionComponent<Props> = ({ setHostedFields, setError, setLoading, setCardValid, threeDSecureEnabled = false }) => {
  const [hostedFields, error, loading, valid] = useBraintreeHostedFields('', threeDSecureEnabled)

  setHostedFields?.(hostedFields)
  setError?.(error)
  setLoading?.(loading)
  setCardValid?.(valid)

  return <div>I am hooked!</div>
}

const setHostedFields = jest.fn()
const setError = jest.fn()
const setLoading = jest.fn()
const setCardValid = jest.fn()

const mountWrapper = (props: Props = {}) => mount(<TestComponent setCardValid={setCardValid} setError={setError} setHostedFields={setHostedFields} setLoading={setLoading} {...props} />)

afterEach(() => { jest.restoreAllMocks() })

it('should return some values by default', async () => {
  mountWrapper()
  expect(setHostedFields).toHaveBeenLastCalledWith(undefined)
  expect(setError).toHaveBeenLastCalledWith(undefined)
  expect(setLoading).toHaveBeenLastCalledWith(true)
  expect(setCardValid).toHaveBeenLastCalledWith(false)

  await waitForPromises()
})

describe('when hosted fields are created', () => {
  it('should return hosted fields', async () => {
    const hostedFields = expect.any(Object)

    mountWrapper()
    await waitForPromises()

    expect(setHostedFields).toHaveBeenLastCalledWith(hostedFields)
  })

  it('should validate the fields', async () => {
    function mockHostedFields (fields: unknown): void {
      jest.spyOn(createHostedFields, 'createHostedFields')
        .mockResolvedValueOnce({
          getState: () => ({ fields }),
          on: (event: string, cb: () => void) => { cb() }
        } as HostedFields)
    }

    mockHostedFields({ ccv: { isValid: false } })
    mountWrapper()
    await waitForPromises()
    expect(setCardValid).toHaveBeenLastCalledWith(false)
    expect(setLoading).toHaveBeenLastCalledWith(false)

    mockHostedFields({ ccv: { isValid: true } })
    mountWrapper()
    await waitForPromises()
    expect(setCardValid).toHaveBeenLastCalledWith(true)
    expect(setLoading).toHaveBeenLastCalledWith(false)
  })

  it('should finish loading', async () => {
    mountWrapper()
    expect(setLoading).toHaveBeenLastCalledWith(true)

    await waitForPromises()
    expect(setLoading).toHaveBeenLastCalledWith(false)
  })

  it('should get nonce without 3DS', async () => {
    let hostedFields: CustomHostedFields | undefined

    mountWrapper({ setHostedFields: (hf) => { hostedFields = hf }, threeDSecureEnabled: false })

    await waitForPromises()

    const nonce = await hostedFields!.getNonce({} as BillingAddress)
    expect(nonce).toEqual('This is non-cense')
  })

  it('should get nonce with 3DS', async () => {
    let hostedFields: CustomHostedFields | undefined

    mountWrapper({ setHostedFields: (hf) => { hostedFields = hf }, threeDSecureEnabled: true })

    await waitForPromises()

    const nonce = await hostedFields!.getNonce({} as BillingAddress)
    expect(nonce).toEqual('This is a 3DS verified transaction')
  })
})

describe('when hosted fields are not created', () => {
  beforeEach(() => {
    jest.spyOn(createHostedFields, 'createHostedFields').mockRejectedValue('Foh!')
  })

  it('should catch any errors', async () => {
    mountWrapper()
    await waitForPromises()
    expect(setError).toHaveBeenLastCalledWith('Foh!')
  })

  it('should finish loading anyway', async () => {
    mountWrapper()
    await waitForPromises()
    expect(setLoading).toHaveBeenLastCalledWith(false)
  })

  it('should not instantiate hosted fields', async () => {
    mountWrapper()
    await waitForPromises()
    expect(setHostedFields).toHaveBeenLastCalledWith(undefined)
  })
})
