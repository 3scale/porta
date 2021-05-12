// @flow

import React, { useState, useEffect, useRef } from 'react'
import {
  BraintreeUserFields,
  BraintreeCardFields,
  BraintreeBillingAddressFields,
  BraintreeSubmitFields,
  createHostedFieldsInstance,
  create3DSecureInstance,
  validationConstraints,
  hostedFieldOptions,
  veryfyCard
} from 'PaymentGateways'
import hostedFields from 'braintree-web/hosted-fields'
import threeDSecure from 'braintree-web/three-d-secure'
import { CSRFToken } from 'utilities/CSRFToken'
import validate from 'validate.js'
import './BraintreeCustomerForm.scss'

import type { Node } from 'react'
import type { BraintreeFormProps, BillingAddressData } from 'PaymentGateways'

const BraintreeForm = ({
  braintreeClient,
  billingAddress,
  threeDSecureEnabled,
  formActionPath,
  countriesList,
  selectedCountryCode
}: BraintreeFormProps): Node => {
  const formRef = useRef<HTMLFormElement | null>(null)
  // eslint-disable-next-line flowtype/no-weak-types
  const [hostedFieldsInstance, setHostedFieldsInstance] = useState<any>(null)
  const [braintreeNonceValue, setBraintreeNonceValue] = useState('')
  const [billingAddressData, setBillingAddressData] = useState<BillingAddressData>(billingAddress)
  const [isCardValid, setIsCardValid] = useState(false)
  const [formErrors, setFormErrors] = useState(validate(formRef, validationConstraints))
  const [cardError, setCardError] = useState(null)
  const [isLoading, setIsLoading] = useState(false)
  const isFormValid = isCardValid && !formErrors && !isLoading

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      const HFInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions, setIsCardValid, setCardError)
      setHostedFieldsInstance(HFInstance)
    }
    getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  const get3DSecureNonce = async (payload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient)
    const response = await veryfyCard(threeDSecureInstance, payload, billingAddressData)
    const error = response.name === 'BraintreeError'
      ? response.code === 'THREEDS_LOOKUP_VALIDATION_ERROR' ? response.details.originalError.details.originalError.error.message : response.message
      : null
    const nonce = response.nonce || null

    return {
      error,
      nonce
    }
  }

  const clearHostedFields = () => {
    hostedFieldsInstance.clear('number')
    hostedFieldsInstance.clear('cvv')
    hostedFieldsInstance.clear('expirationDate')
  }

  const validateForm = (event: SyntheticEvent<HTMLFormElement>) => {
    const validationErrors = validate(event.currentTarget, validationConstraints)
    setFormErrors(validationErrors)
  }

  const handleCardError = (error: string) => {
    setCardError(`Credit card errors found: ${error}. Please correct your CC data.`)
    clearHostedFields()
    setIsLoading(false)
  }

  const onSubmit = async (event: SyntheticEvent<HTMLInputElement>) => {
    event.preventDefault()
    if (hostedFieldsInstance) {
      setIsLoading(true)
      const payload = await hostedFieldsInstance.tokenize()
        .then(payload => payload)
        .catch(error => console.error(error))

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
      id="customer_form"
      className="form-horizontal customer"
      action={formActionPath}
      ref={formRef}
      onChange={validateForm}
    >
      <input name="utf8" type="hidden" value="✓"/>
      <CSRFToken/>
      <fieldset>
        <p className="required-fields">All fields marked with an asterisk ( * ) are mandatory</p>
        <BraintreeUserFields/>
      </fieldset>
      <fieldset>
        <BraintreeCardFields />
        {cardError && <p className="alert alert-danger">{cardError}</p>}
      </fieldset>
      <fieldset>
        <BraintreeBillingAddressFields
          billingAddressData={billingAddressData}
          setBillingAddressData={setBillingAddressData}
          selectedCountryCode={selectedCountryCode}
          countriesList={JSON.parse(countriesList)}
        />
      </fieldset>
      <fieldset>
        <BraintreeSubmitFields
          onSubmitForm={onSubmit}
          isFormValid={isFormValid}
        />
      </fieldset>
      <input type="hidden" name="braintree[nonce]" id="braintree_nonce" value={braintreeNonceValue} />
    </form>
  )
}

export { BraintreeForm }
