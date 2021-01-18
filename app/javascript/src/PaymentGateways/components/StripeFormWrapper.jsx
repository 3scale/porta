// @flow

import React from 'react'
import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CardForm } from 'PaymentGateways'
import 'PaymentGateways/styles/stripe.scss'

type Props = {
  stripePublishableKey: string,
  setupIntentSecret: string,
  billingAddressDetails: {
    line1: string,
    line2: string,
    city: string,
    state: string,
    postal_code: string,
    country: string
  },
  successUrl: string,
  isCreditCardStored: boolean
}

const StripeElementsForm = ({ stripePublishableKey, setupIntentSecret, billingAddressDetails, successUrl, isCreditCardStored }: Props) => {
  const stripePromise = loadStripe(stripePublishableKey)

  return (
    <Elements stripe={stripePromise}>
      <CardForm
        setupIntentSecret={setupIntentSecret}
        billingAddressDetails={billingAddressDetails}
        successUrl={successUrl}
        isCreditCardStored={isCreditCardStored}
      />
    </Elements>
  )
}

const StripeFormWrapper = (props: Props, containerId: string) => (
  createReactWrapper(<StripeElementsForm {...props} />, containerId)
)

export { StripeElementsForm, StripeFormWrapper }
