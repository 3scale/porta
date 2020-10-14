// @flow

import React from 'react'
import {
  Button,
  Card,
  CardActions,
  CardBody,
  CardHeader,
  CardFooter,
  Title,
  DataList
} from '@patternfly/react-core'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import { APIDataListItem } from 'Dashboard/components/APIDataListItem'
import { createReactWrapper } from 'utilities/createReactWrapper'

import 'Dashboard/styles/dashboard.scss'
import 'patternflyStyles/dashboard'

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

const BackendsWidget = (props: Props) => (
  <Card className="pf-c-card">
    <CardHeader>
      <div className="dashboard-list-icon-title-layout">
        <CubesIcon/>
        <Title headingLevel="h1" size="xl">
          Backends
        </Title>
        <CardActions>
          <Button component="a" variant="primary" href={props.newBackendPath}>
            Create Backend
          </Button>
        </CardActions>
      </div>
      <div className="dashboard-list-subtitle">
        Recently updated
      </div>
    </CardHeader>
    <CardBody>
      <DataList>
        {props.backends.map(api => <APIDataListItem api={api} key={api.id}/>)}
      </DataList>
    </CardBody>
    <CardFooter>
      <Button variant="link" component="a" isInline href={props.backendsPath}>
        Explore all Backends
      </Button>
    </CardFooter>
  </Card>
)

const BackendsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<BackendsWidget {...props} />, containerId)

export { BackendsWidgetWrapper }
