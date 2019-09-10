import React from 'react'
import {
  Card,
  CardHead,
  CardHeader,
  CardBody,
  Title
} from '@patternfly/react-core'
import {AudienceNav} from 'Dashboard/components/audience/AudienceNav'
import { createReactWrapper } from 'utilities/createReactWrapper'

const Audience = () => (
  <Card>
    <CardHead>
      <Title headingLevel="h1" size="lg">
        Audience</Title>
    </CardHead>
    <CardHeader>
      <AudienceNav/>
    </CardHeader>

    <CardBody>
      1 Signups
    </CardBody>
  </Card>
)

const AudienceWrapper = (props, containerId) => createReactWrapper(<Audience {...props} />, containerId)

export {
  Audience,
  AudienceWrapper
}
