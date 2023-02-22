import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { StripeCardForm } from 'PaymentGateways/stripe/components/StripeCardForm'

import type { BillingAddress } from 'PaymentGateways/stripe/types'

import './StripeFormWrapper.scss'

interface Props {
  stripePublishableKey: string;
  setupIntentSecret: string;
  billingAddressDetails: BillingAddress;
  successUrl: string;
  isCreditCardStored: boolean;
}

const StripeElementsForm: React.FunctionComponent<Props> = ({
  stripePublishableKey,
  setupIntentSecret,
  billingAddressDetails,
  successUrl,
  isCreditCardStored
}) => {
  const stripePromise = loadStripe(stripePublishableKey)

  return (
    <Elements stripe={stripePromise}>
      <StripeCardForm
        billingAddressDetails={billingAddressDetails}
        isCreditCardStored={isCreditCardStored}
        setupIntentSecret={setupIntentSecret}
        successUrl={successUrl}
      />
    </Elements>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const StripeFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<StripeElementsForm {...props} />, containerId) }

export { StripeElementsForm, StripeFormWrapper, Props }
