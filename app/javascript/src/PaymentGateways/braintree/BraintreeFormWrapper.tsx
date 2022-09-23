import * as React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { BraintreeForm } from 'PaymentGateways'
import { Props as BraintreeFormProps } from 'PaymentGateways/braintree/BraintreeForm'

const BraintreeFormWrapper = (props: BraintreeFormProps, containerId: string): void => createReactWrapper(<BraintreeForm { ...props } />, containerId)

export { BraintreeFormWrapper }
