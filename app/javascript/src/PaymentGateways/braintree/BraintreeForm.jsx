/* eslint-disable no-console */
// @flow

// Todos:
// get billingAdrres
// handle not 3D secure scenario

import React, { useState, useEffect, useRef } from 'react'
import {
  BraintreeUserFields,
  BraintreeCardFields,
  BraintreeBillingAddressFields,
  BraintreeSubmitFields,
  createHostedFieldsInstance,
  create3DSecureInstance,
  hostedFieldOptions,
  veryfyCard
} from 'PaymentGateways'
import hostedFields from 'braintree-web/hosted-fields'
import threeDSecure from 'braintree-web/three-d-secure'
import { CSRFToken } from 'utilities/utils'

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
  const hostedFieldsInstanceRef = useRef({})
  const [braintreeNonceValue, setBraintreeNonceValue] = useState('')

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      const hostedFieldsInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions)
      hostedFieldsInstanceRef.current = hostedFieldsInstance
    }
    getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  const verifyCard3DSecure = async (payload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient, payload)
    const response = await veryfyCard(threeDSecureInstance, payload)
    setBraintreeNonceValue(response.nonce)
    console.log(braintreeNonceValue)
  }

  const onSubmit = async (event) => {
    event.preventDefault()
    const payload = await hostedFieldsInstanceRef.current.tokenize()
      .then(payload => payload)
      .catch(error => console.error(error))

    if (threeDSecureEnabled) {
      verifyCard3DSecure(payload)
    } else {
      console.log('Not 3D secure')
    }
  }

  return (
    <form
      id="customer_form"
      className="form-horizontal customer"
      action={formActionPath}
      onSubmit={onSubmit}
      ref={formRef}
    >
      <input name="utf8" type="hidden" value="✓"/>
      <CSRFToken/>
      <fieldset>
        <BraintreeUserFields/>
      </fieldset>
      <fieldset>
        <BraintreeCardFields/>
      </fieldset>
      <fieldset>
        <BraintreeBillingAddressFields
          billingAddress={billingAddress}
          selectedCountryCode={selectedCountryCode}
          countriesList={JSON.parse(countriesList)}
        />
      </fieldset>
      <fieldset>
        <BraintreeSubmitFields/>
      </fieldset>
      <input type="hidden" name="braintree[nonce]" id="braintree_nonce" value={braintreeNonceValue} />
    </form>
  )
}

export { BraintreeForm }
