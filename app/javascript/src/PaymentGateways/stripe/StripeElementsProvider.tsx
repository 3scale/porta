import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'

import type { FunctionComponent, PropsWithChildren } from 'react'

interface Props {
  publishableKey: string;
}

/**
 * This component only exists because useElements needs to wrapped around <Elements />. It can be
 * done within the same component.
 */
const StripeElementsProvider: FunctionComponent<PropsWithChildren<Props>> = ({ publishableKey, children }) => {
  const stripePromise = loadStripe(publishableKey)

  return (
    <Elements stripe={stripePromise}>
      {children}
    </Elements>
  )
}

export { StripeElementsProvider, Props }
