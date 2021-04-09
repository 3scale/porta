// @flow

import React from 'react'
import {
  BraintreeUserFields,
  BraintreeCardFields,
  BraintreeBillingAddressFields,
  BraintreeSubmitFields
} from 'PaymentGateways'
import { CSRFToken } from 'utilities/utils'
import type { Props } from 'PaymentGateways'

const BraintreeForm = ({
  clientToken,
  billingAddress,
  threeDSecureEnabled,
  formActionPath,
  countriesList
}: Props): React.Node => {
  return (
    <form
      id="customer_form"
      className="form-horizontal customer"
      action={formActionPath}
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
          countriesList={JSON.parse(countriesList)}
        />
      </fieldset>
      <fieldset>
        <BraintreeSubmitFields/>
      </fieldset>
      <input type="hidden" name="braintree[nonce]" id="braintree_nonce"/>
    </form>
  )
}

export { BraintreeForm }
