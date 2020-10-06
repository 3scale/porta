// @flow

import React from 'react';
import { Card } from '@patternfly/react-core';
import 'Dashboard/styles/dashboard.scss';
import 'patternflyStyles/dashboard';

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
    <Card>
      Backends go here
    </Card>
  )
}

const BackendsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<BackendsWidget {...props} />, containerId)

export { BackendsWidgetWrapper }
