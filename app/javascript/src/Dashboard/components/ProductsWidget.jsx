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
import 'Dashboard/styles/dashboard.scss'
import { APIDataListItem } from 'Dashboard/components/APIDataListItem'
import 'patternflyStyles/dashboard'

import { createReactWrapper } from 'utilities/createReactWrapper'

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
}

const ProductsWidget = (props: Props) => {
  console.log('what are the props' + JSON.stringify(props))
  console.log('what are the props 2' + JSON.stringify(props.products[0].name))

  console.log('what is props length' + props.products.length)

  return (
    <Card className="pf-c-card">
      <CardHeader>
        <div className="dashboard-list-icon-title-layout">
          <CubesIcon/>
          <Title headingLevel="h1" size="xl">
            Products
          </Title>
          <CardActions>
            <Button component="a" variant="primary" href={props.newProductPath}>
              Create Product
            </Button>
          </CardActions>
        </div>
        <div className="dashboard-list-subtitle">
          Recently updated
        </div>
      </CardHeader>
      <CardBody>
        <DataList>
          {props.products.map(api => <APIDataListItem api={api} key={api.id}/>)}
        </DataList>
      </CardBody>
      <CardFooter>
        <Button variant="link" component="a" isInline href={props.productsPath}>
          Explore all Products
        </Button>
      </CardFooter>
    </Card>
  )
}

const ProductsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsWidget {...props} />, containerId)

export { ProductsWidgetWrapper }
