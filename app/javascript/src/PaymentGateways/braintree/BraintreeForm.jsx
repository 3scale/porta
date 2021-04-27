/* eslint-disable no-console */
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
import { CSRFToken } from 'utilities/utils'
import validate from 'validate.js'

import type { Node } from 'react'
import type { BraintreeFormProps } from 'PaymentGateways'

const BraintreeForm = ({
  braintreeClient,
  billingAddress,
  threeDSecureEnabled,
  formActionPath,
  countriesList,
  selectedCountryCode
}: BraintreeFormProps): Node => {
  const formRef = useRef<HTMLFormElement | null>(null)
  const [hostedFieldsInstance, setHostedFieldsInstance] = useState(null)
  const [braintreeNonceValue, setBraintreeNonceValue] = useState('test-mode-placeholder')
  const [billingAddressData, setBillingAddressData] = useState(billingAddress)
  const [isCardValid, setIsCardValid] = useState(false)
  const [isFormValid, setIsFormValid] = useState(false)
  const [formErrors, setFormErrors] = useState(null)
  const [isAwaiting, setIsAwaiting] = useState(false)

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      const HFInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions, setIsCardValid)
      setHostedFieldsInstance(HFInstance)
    }
    getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue !== 'test-mode-placeholder' && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  useEffect(() => {
    const formValid = isCardValid && !formErrors && !isAwaiting
    setIsFormValid(formValid)
  }, [formErrors, isCardValid, isAwaiting])

  const get3DSecureNonce = async (payload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient)
    const response = await veryfyCard(threeDSecureInstance, payload, billingAddressData)
    if (response.name === 'BraintreeError') {
      throw new Error(response.details.originalError.details.originalError.error.message)
    } else {
      return response.nonce
    }
  }

  const onFormChange = (event) => {
    const validationErrors = validate(event.currentTarget, validationConstraints)
    setFormErrors(validationErrors)
  }

  const onSubmit = async (event) => {
    event.preventDefault()
    if (hostedFieldsInstance) {
      setIsAwaiting(true)
      const payload = await hostedFieldsInstance.tokenize()
        .then(payload => payload)
        .catch(error => console.error(error))
      const nonce = threeDSecureEnabled ? await get3DSecureNonce(payload) : payload.nonce
      setBraintreeNonceValue(nonce)
      setIsAwaiting(false)
    }
  }

  return (
    <form
      id="customer_form"
      className="form-horizontal customer"
      action={formActionPath}
      ref={formRef}
      onChange={onFormChange}
    >
      <input name="utf8" type="hidden" value="✓"/>
      <CSRFToken/>
      <fieldset>
        <BraintreeUserFields/>
      </fieldset>
      <fieldset>
        <BraintreeCardFields />
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
