// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  // props here
}

const MethodsTable = (props: Props): React.Node => {
  // logic here

  return (
    <div>MethodsTable</div>
  )
}

const MethodsTableWrapper = (props: Props, containerId: string): void => createReactWrapper(<MethodsTable {...props} />, containerId)

export { MethodsTable, MethodsTableWrapper }
