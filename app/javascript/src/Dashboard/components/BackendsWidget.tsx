import {
  Button,
  Card,
  CardActions,
  CardBody,
  CardFooter,
  CardTitle,
  DataList,
  Title
} from '@patternfly/react-core'
import CubeIcon from '@patternfly/react-icons/dist/js/icons/cube-icon'

import { APIDataListItem } from 'Dashboard/components/APIDataListItem'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

interface Props {
  newBackendPath: string | null;
  backendsPath: string;
  backends: {
    id: number;
    link: string;
    links: {
      name: string;
      path: string;
    }[];
    name: string;
    type: string;
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
    updated_at: string;
  }[];
}

const BackendsWidget: FunctionComponent<Props> = ({
  newBackendPath,
  backendsPath,
  backends
}) => (
  <Card>
    <CardTitle>
      <div className="dashboard-list-icon-title-layout">
        <CubeIcon className="pf-u-mr-sm" size="lg" />
        <Title headingLevel="h1" size="xl">
          Backends
        </Title>
        <CardActions>
          {newBackendPath && (
            <Button
              component="a"
              data-testid="dashboardCreateBackend-buttonLink"
              href={newBackendPath}
              variant="primary"
            >
              Create Backend
            </Button>
          )}
        </CardActions>
      </div>
      <div className="pf-u-mt-sm">
        Last updated
      </div>
    </CardTitle>
    <CardBody>
      <DataList aria-label="">
        {backends.map(api => <APIDataListItem key={api.id} api={api} />)}
      </DataList>
    </CardBody>
    <CardFooter>
      <Button isInline component="a" href={backendsPath} variant="link">
        Explore all Backends
      </Button>
    </CardFooter>
  </Card>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendsWidgetWrapper = (props: Props, containerId: string): void => { createReactWrapper(<BackendsWidget {...props} />, containerId) }

export type { Props }
export { BackendsWidget, BackendsWidgetWrapper }
