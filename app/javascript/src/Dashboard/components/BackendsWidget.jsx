// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  newBackendPath: string,
  backendsPath: string,
  backends: Array<{
    name: string,
    path: string,
    updatedAt: string,
    links: Array<{
      name: string,
      path: string
    }>
  }>
}

const BackendsWidget = (props: Props) => {
  console.log(props)

  return (
    <div>Backends</div>
  )
}

const BackendsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<BackendsWidget {...props} />, containerId)

export { BackendsWidgetWrapper }
