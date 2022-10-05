import { useEffect, useRef, useState } from 'react'
import validate from 'validate.js'
import { hostedFields, threeDSecure } from 'braintree-web'
import { CSRFToken } from 'utilities/CSRFToken'
import { validationConstraints, createHostedFieldsInstance, hostedFieldOptions, create3DSecureInstance, veryfyCard } from 'PaymentGateways/braintree/braintree'
import { BraintreeBillingAddressFields } from 'PaymentGateways/braintree/BraintreeBillingAddressFields'
import { BraintreeCardFields } from 'PaymentGateways/braintree/BraintreeCardFields'
import { BraintreeSubmitFields } from 'PaymentGateways/braintree/BraintreeSubmitFields'
import { BraintreeUserFields } from 'PaymentGateways/braintree/BraintreeUserFields'

import type { FunctionComponent } from 'react'
import type { Client, HostedFields, HostedFieldsTokenizePayload, ThreeDSecure, ThreeDSecureVerifyPayload } from 'braintree-web'
import type { BillingAddressData } from 'PaymentGateways/braintree/types'

import './BraintreeCustomerForm.scss'

const CC_ERROR_MESSAGE = 'An error occurred, please review your CC details or try later.'

type Props = {
  braintreeClient: Client,
  billingAddress: BillingAddressData,
  threeDSecureEnabled: boolean,
  formActionPath: string,
  countriesList: string,
  selectedCountryCode: string
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
  const [formErrors, setFormErrors] = useState(validate(formRef, validationConstraints))
  const [cardError, setCardError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const isFormValid = isCardValid && !formErrors && !isLoading

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      const HFInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions, setIsCardValid, setCardError)
      setHostedFieldsInstance(HFInstance as HostedFields)
    }
    getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  const get3DSecureError = (response: ThreeDSecureVerifyPayload) => {
    const { threeDSecureInfo } = response
    const { status: message = null } = threeDSecureInfo as any // TODO: Types must be outdated, status is missing from ThreeDSecureInfo
    return message && message.match(/authenticate_(attempt_)?successful/) ? null : CC_ERROR_MESSAGE
  }

  const get3DSecureNonce = async (payload: HostedFieldsTokenizePayload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient) as ThreeDSecure
    const response = await veryfyCard(threeDSecureInstance, payload, billingAddressData)

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
    const validationErrors = validate(event.currentTarget, validationConstraints)
    setFormErrors(validationErrors)
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
        .then(payload => payload)
        .catch(error => console.error(error)) as HostedFieldsTokenizePayload

      const response3Dsecure = threeDSecureEnabled ? await get3DSecureNonce(payload) : null
      if (response3Dsecure && response3Dsecure.error) {
        handleCardError(response3Dsecure.error)
        return
      }
      const nonce = response3Dsecure ? response3Dsecure.nonce : payload.nonce
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
          countriesList={JSON.parse(countriesList)}
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
      <input id="braintree_nonce" name="braintree[nonce]" type="hidden" value={braintreeNonceValue as string} /> {/* FIXME: braintreeNonceValue should be string | undefined */}
    </form>
  )
}

export { BraintreeForm, Props }
