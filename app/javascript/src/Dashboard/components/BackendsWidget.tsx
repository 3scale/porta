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
import { CubeIcon } from '@patternfly/react-icons'
import { APIDataListItem } from 'Dashboard/components/APIDataListItem'
import { createReactWrapper } from 'utilities'

import 'Dashboard/styles/dashboard.scss'

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
    // eslint-disable-next-line camelcase
    updated_at: string
  }>
};

const BackendsWidget = ({
  newBackendPath,
  backendsPath,
  backends
}: Props) => (
  <Card className="pf-c-card">
    <CardHeader>
      <div className="dashboard-list-icon-title-layout">
        <CubeIcon/>
        <Title headingLevel="h1" size="xl">
          Backends
        </Title>
        <CardActions>
          <Button
            data-testid="dashboardCreateBackend-buttonLink"
            component="a"
            variant="primary"
            href={newBackendPath}
          >
            Create Backend
          </Button>
        </CardActions>
      </div>
      <div className="dashboard-list-subtitle">
        Last updated
      </div>
    </CardHeader>
    <CardBody>
      <DataList aria-label="">
        {backends.map(api => <APIDataListItem api={api} key={api.id}/>)}
      </DataList>
    </CardBody>
    <CardFooter>
      <Button variant="link" component="a" isInline href={backendsPath}>
        Explore all Backends
      </Button>
    </CardFooter>
  </Card>
)

const BackendsWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendsWidget {...props} />, containerId)

export { BackendsWidget, BackendsWidgetWrapper, Props }
