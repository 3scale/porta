import * as React from 'react';
import { createReactWrapper } from 'utilities/createReactWrapper'
import { BraintreeForm } from 'PaymentGateways'
import type { BraintreeFormProps } from 'PaymentGateways'

const BraintreeFormWrapper = (props: BraintreeFormProps, containerId: string): void => createReactWrapper(<BraintreeForm { ...props } />, containerId)

export { BraintreeFormWrapper }
