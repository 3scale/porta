// @flow

// Todos:
// get billingAdrres
// handle not 3D secure scenario

import React, { useState, useEffect, useRef } from 'react'
import client from 'braintree-web/client'
import hostedFields from 'braintree-web/hosted-fields'
import threeDSecure from 'braintree-web/three-d-secure'
import {
  BraintreeUserFields,
  BraintreeCardFields,
  BraintreeBillingAddressFields,
  BraintreeSubmitFields,
  hostedFieldOptions,
  createBraintreeClient,
  createHostedFieldsInstance,
  create3DSecureInstance,
  veryfyCard
} from 'PaymentGateways'
import { CSRFToken } from 'utilities/utils'

import type { Node } from 'react'
import type { BraintreeFormProps } from 'PaymentGateways'

const BraintreeForm = ({
  clientToken,
  billingAddress,
  threeDSecureEnabled,
  formActionPath,
  countriesList,
  selectedCountryCode
}: BraintreeFormProps): Node => {
  const formRef = useRef<null | HTMLFormElement>(null)
  const [hostedFieldsInstance, setHostedFieldsInstance] = useState(null)
  const [clientInstance, setClientInstance] = useState(null)
  const [payload, setPayload] = useState(null)
  const [braintreeNonceValue, setBraintreeNonceValue] = useState('')

  useEffect(() => {
    const setUpBraintree = async () => {
      const braintreeClient = await createBraintreeClient(client, clientToken)
      const HFInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions)
      setClientInstance(braintreeClient)
      setHostedFieldsInstance(HFInstance)
    }
    setUpBraintree()
  }, [])

  useEffect(() => {
    const get3DSecureInstance = async () => {
      if (payload) {
        const threeDSecureInstance = await create3DSecureInstance(threeDSecure, clientInstance, payload)
        const response = await veryfyCard(threeDSecureInstance, payload)
        setBraintreeNonceValue(response.nonce)
        formRef.current.submit()
      }
    }
    get3DSecureInstance()
  }, [payload])

  const onSubmit = async (event) => {
    event.preventDefault()
    const _payload = await hostedFieldsInstance.tokenize()
      .then(payload => payload)
      .catch(error => console.error(error))
    setPayload(_payload)
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
