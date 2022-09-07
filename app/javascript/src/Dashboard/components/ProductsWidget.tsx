import React from 'react';
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
import { createReactWrapper } from 'utilities'

import 'Dashboard/styles/dashboard.scss'

type Props = {
  newProductPath: string,
  productsPath: string,
  products: Array<{
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
};

const ProductsWidget = ({
  newProductPath,
  productsPath,
  products,
}: Props) => (
  <Card className="pf-c-card">
    <CardHeader>
      <div className="dashboard-list-icon-title-layout">
        <CubesIcon/>
        <Title headingLevel="h1" size="xl">
          Products
        </Title>
        <CardActions>
          <Button
            data-testid="dashboardCreateProduct-buttonLink"
            component="a"
            variant="primary"
            href={newProductPath}
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
        {products.map(api => <APIDataListItem api={api} key={api.id}/>)}
      </DataList>
    </CardBody>
    <CardFooter>
      <Button variant="link" component="a" isInline href={productsPath}>
        Explore all Products
      </Button>
    </CardFooter>
  </Card>
)

const ProductsWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductsWidget {...props} />, containerId)

export { ProductsWidgetWrapper }
