import { createReactWrapper } from 'utilities/createReactWrapper'
import { BraintreeForm } from 'PaymentGateways/braintree/BraintreeForm'

import type { Props as BraintreeFormProps } from 'PaymentGateways/braintree/BraintreeForm'

// eslint-disable-next-line react/jsx-props-no-spreading
const BraintreeFormWrapper = (props: BraintreeFormProps, containerId: string): void => createReactWrapper(<BraintreeForm {...props} />, containerId)

export { BraintreeFormWrapper }
