/* eslint-disable react/jsx-props-no-spreading */

import { StripeElementsForm } from 'PaymentGateways/stripe/StripeElementsForm'
import { StripeElementsProvider } from 'PaymentGateways/stripe/StripeElementsProvider'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = React.ComponentProps<typeof StripeElementsForm> & React.ComponentProps<typeof StripeElementsProvider>

const StripeFormWrapper = ({ publishableKey, ...stripeElementsFormProps }: Props, containerId: string): void => {
  createReactWrapper(
    <StripeElementsProvider publishableKey={publishableKey}>
      <StripeElementsForm {...stripeElementsFormProps} />
    </StripeElementsProvider>,
    containerId
  )
}

export { StripeFormWrapper }
