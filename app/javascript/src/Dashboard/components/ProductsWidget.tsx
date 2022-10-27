import {
  Button,
  Card,
  CardActions,
  CardBody,
  CardFooter,
  CardHeader,
  DataList,
  Title
} from '@patternfly/react-core'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import { APIDataListItem } from 'Dashboard/components/APIDataListItem'
import { createReactWrapper } from 'utilities/createReactWrapper'
import 'Dashboard/styles/dashboard.scss'

import type { FunctionComponent } from 'react'

interface Props {
  newProductPath: string;
  productsPath: string;
  products: {
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

const ProductsWidget: FunctionComponent<Props> = ({
  newProductPath,
  productsPath,
  products
}) => (
  <Card className="pf-c-card">
    <CardHeader>
      <div className="dashboard-list-icon-title-layout">
        <CubesIcon />
        <Title headingLevel="h1" size="xl">
          Products
        </Title>
        <CardActions>
          <Button
            component="a"
            data-testid="dashboardCreateProduct-buttonLink"
            href={newProductPath}
            variant="primary"
          >
            Create Product
          </Button>
        </CardActions>
      </div>
      <div className="dashboard-list-subtitle">
        Last updated
      </div>
    </CardHeader>
    <CardBody>
      <DataList aria-label="">
        {products.map(api => <APIDataListItem key={api.id} api={api} />)}
      </DataList>
    </CardBody>
    <CardFooter>
      <Button isInline component="a" href={productsPath} variant="link">
        Explore all Products
      </Button>
    </CardFooter>
  </Card>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const ProductsWidgetWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ProductsWidget {...props} />, containerId) }

export { ProductsWidget, ProductsWidgetWrapper, Props }
