import { useEffect, useRef, useState } from 'react'
import validate from 'validate.js'
import { hostedFields, threeDSecure } from 'braintree-web'

import { CSRFToken } from 'utilities/CSRFToken'
import {
  validationConstraints,
  createHostedFieldsInstance,
  hostedFieldOptions,
  create3DSecureInstance,
  veryfyCard as verifyCard
} from 'PaymentGateways/braintree/braintree'
import { BraintreeBillingAddressFields } from 'PaymentGateways/braintree/BraintreeBillingAddressFields'
import { BraintreeCardFields } from 'PaymentGateways/braintree/BraintreeCardFields'
import { BraintreeSubmitFields } from 'PaymentGateways/braintree/BraintreeSubmitFields'
import { BraintreeUserFields } from 'PaymentGateways/braintree/BraintreeUserFields'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { Client, HostedFields, HostedFieldsTokenizePayload, ThreeDSecure, ThreeDSecureVerifyPayload } from 'braintree-web'
import type { ThreeDSecureInfo } from 'braintree-web/modules/three-d-secure'
import type { BillingAddressData } from 'PaymentGateways/braintree/types'

import './BraintreeCustomerForm.scss'

const CC_ERROR_MESSAGE = 'An error occurred, please review your CC details or try later.'

interface Props {
  braintreeClient: Client;
  billingAddress: BillingAddressData;
  threeDSecureEnabled: boolean;
  formActionPath: string;
  countriesList: string;
  selectedCountryCode: string;
}

const BraintreeForm: FunctionComponent<Props> = ({
  braintreeClient,
  billingAddress,
  threeDSecureEnabled,
  formActionPath,
  countriesList,
  selectedCountryCode
}) => {
  const formRef = useRef<HTMLFormElement | null>(null)
  const [hostedFieldsInstance, setHostedFieldsInstance] = useState<HostedFields | null>(null)
  const [braintreeNonceValue, setBraintreeNonceValue] = useState<string | null>('')
  const [billingAddressData, setBillingAddressData] = useState<BillingAddressData>(billingAddress)
  const [isCardValid, setIsCardValid] = useState(false)
  const [formErrors, setFormErrors] = useState<unknown>(validate(formRef, validationConstraints))
  const [cardError, setCardError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const isFormValid = isCardValid && !formErrors && !isLoading

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      setHostedFieldsInstance(await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions, setIsCardValid, setCardError) as HostedFields)
    }
    void getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  const get3DSecureError = (response: ThreeDSecureVerifyPayload) => {
    const { threeDSecureInfo } = response
    const { status: message = null } = threeDSecureInfo as (ThreeDSecureInfo & { status: string }) // HACK: Types must be outdated, status is missing from ThreeDSecureInfo
    return message?.match(/authenticate_(attempt_)?successful/) ? null : CC_ERROR_MESSAGE
  }

  const get3DSecureNonce = async (payload: HostedFieldsTokenizePayload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient) as ThreeDSecure
    const response = await verifyCard(threeDSecureInstance, payload, billingAddressData) as ThreeDSecureVerifyPayload

    const error = get3DSecureError(response)
    const nonce = response.nonce || null

    return {
      error,
      nonce
    }
  }

  const clearHostedFields = () => {
    if (hostedFieldsInstance) {
      hostedFieldsInstance.clear('number')
      hostedFieldsInstance.clear('cvv')
      hostedFieldsInstance.clear('expirationDate')
    }
  }

  const validateForm = (event: React.SyntheticEvent<HTMLFormElement>) => {
    setFormErrors(validate(event.currentTarget, validationConstraints))
  }

  const handleCardError = (error: string) => {
    setCardError(error)
    clearHostedFields()
    setIsLoading(false)
  }

  const onSubmit = async (event: React.MouseEvent<HTMLButtonElement>) => {
    event.preventDefault()
    if (hostedFieldsInstance) {
      setIsLoading(true)
      const payload = await hostedFieldsInstance.tokenize()
        .catch(error => { console.error(error) })

      // @ts-expect-error tokenize() expects an error, yet payload is assumed to be present. TODO: Fix this mess.
      const response3Dsecure = threeDSecureEnabled ? await get3DSecureNonce(payload) : null
      if (response3Dsecure?.error) {
        handleCardError(response3Dsecure.error)
        return
      }
      // @ts-expect-error cascade previous TODO.
      const nonce = (response3Dsecure ? response3Dsecure.nonce : payload.nonce) as string | null
      setBraintreeNonceValue(nonce)
      setIsLoading(false)
    }
  }

  return (
    <form
      action={formActionPath}
      className="form-horizontal customer"
      id="customer_form"
      ref={formRef}
      onChange={validateForm}
    >
      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />
      <fieldset>
        <p className="required-fields">All fields marked with an asterisk ( * ) are mandatory</p>
        <BraintreeUserFields />
      </fieldset>
      <fieldset>
        <BraintreeCardFields />
        {!!cardError && <p className="alert alert-danger">{cardError}</p>}
      </fieldset>
      <fieldset>
        <BraintreeBillingAddressFields
          billingAddressData={billingAddressData}
          countriesList={JSON.parse(countriesList) as string[][]}
          selectedCountryCode={selectedCountryCode}
          setBillingAddressData={setBillingAddressData}
        />
      </fieldset>
      <fieldset>
        <BraintreeSubmitFields
          isFormValid={isFormValid}
          onSubmitForm={onSubmit}
        />
      </fieldset>
      {/* eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME: braintreeNonceValue should be string | undefined, not null */}
      <input id="braintree_nonce" name="braintree[nonce]" type="hidden" value={braintreeNonceValue!} />
    </form>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BraintreeFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<BraintreeForm {...props} />, containerId) }

export { BraintreeForm, BraintreeFormWrapper, Props }
