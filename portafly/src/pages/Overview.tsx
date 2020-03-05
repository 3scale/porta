import React from 'react'
import { useA11yRouteChange, useDocumentTitle } from 'components'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody
} from '@patternfly/react-core'

const Overview: React.FunctionComponent = () => {
  useA11yRouteChange()
  useDocumentTitle('Overview')
  return (
    <>
      <PageSection variant="light">
        <TextContent>
          <Title size="3xl">Overview</Title>
          <Text>
            <b>PortaFly</b>
            {' '}
            the next gen UI for Porta API MGMT App
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>OHAI</p>
            </TextContent>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Overview
