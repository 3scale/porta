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
    id: number,
    link: string,
    links: Array<{
      name: string,
      path: string
    }>,
    name: string,
    type: string,
    updated_at: string
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
