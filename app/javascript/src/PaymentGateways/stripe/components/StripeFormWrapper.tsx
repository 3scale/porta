import { loadStripe } from '@stripe/stripe-js'
import { Elements } from '@stripe/react-stripe-js'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { StripeCardForm } from 'PaymentGateways/stripe/components/StripeCardForm'

import './StripeFormWrapper.scss'

interface Props {
  stripePublishableKey: string;
  setupIntentSecret: string;
  billingAddressDetails: {
    line1: string;
    line2: string;
    city: string;
    state: string;
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
    postal_code: string;
    country: string;
  };
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
