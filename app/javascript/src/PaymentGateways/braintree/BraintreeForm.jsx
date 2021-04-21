// @flow

// Todos:
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
  const [hostedFieldsInstance, setHostedFieldsInstance] = useState(null)
  const [braintreeNonceValue, setBraintreeNonceValue] = useState('')
  const [billingAddressData, setBillingAddressData] = useState(billingAddress)

  useEffect(() => {
    const getHostedFieldsInstance = async () => {
      const HFInstance = await createHostedFieldsInstance(hostedFields, braintreeClient, hostedFieldOptions)
      setHostedFieldsInstance(HFInstance)
    }
    getHostedFieldsInstance()
  }, [])

  useEffect(() => {
    if (braintreeNonceValue && formRef.current) {
      formRef.current.submit()
    }
  }, [braintreeNonceValue])

  const verifyCard3DSecure = async (payload) => {
    const threeDSecureInstance = await create3DSecureInstance(threeDSecure, braintreeClient)
    const response = await veryfyCard(threeDSecureInstance, payload, billingAddressData)
    setBraintreeNonceValue(response.nonce)
  }

  const onSubmit = async (event) => {
    event.preventDefault()
    if (hostedFieldsInstance) {
      const payload = await hostedFieldsInstance.tokenize()
        .then(payload => payload)
        .catch(error => console.error(error))
      verifyCard3DSecure(payload)
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
          billingAddressData={billingAddressData}
          setBillingAddressData={setBillingAddressData}
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
