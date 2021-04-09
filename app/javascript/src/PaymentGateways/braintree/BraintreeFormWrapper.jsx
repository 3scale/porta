// @flow

import * as React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { BraintreeForm } from 'PaymentGateways'
import type { Props } from 'PaymentGateways'

const BraintreeFormWrapper = (props: Props, containerId: string): void => (
  createReactWrapper(<BraintreeForm { ...props } />, containerId)
)

export { BraintreeForm, BraintreeFormWrapper }
