// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  // props here
}

const MetricsTable = (props: Props): React.Node => {
  // logic here

  return (
    <div>MetricsTable</div>
  )
}

const MetricsTableWrapper = (props: Props, containerId: string): void => createReactWrapper(<MetricsTable {...props} />, containerId)

export { MetricsTable, MetricsTableWrapper }
