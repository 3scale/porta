// @flow

import React, {useState} from 'react';
import {
  Button,
  Card,
  CardActions,
  CardTitle,
  CardBody,
  CardHeader,
  CardFooter,
  PageSection,
  Grid,
  GridItem,
  Title,
  Dropdown,
  DropdownItem,
  DropdownPosition,
  KebabToggle,
  DataList,
  DataListItem,
  DataListCell,
  DataListItemRow,
  DataListItemCells,
  DataListAction
} from '@patternfly/react-core';
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon';
import 'Dashboard/styles/dashboard.scss';
import 'patternflyStyles/dashboard';

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  newProductPath: string,
  productsPath: string,
  products: Array<{
    name: string,
    path: string,
    updatedAt: string,
    links: Array<{
      name: string,
      path: string
    }>
  }>
}

const ProductsWidget = (props: Props) => {
  console.log('what are the props' + JSON.stringify(props));
  console.log('what are the props 2' + JSON.stringify(props.products[0].name));

  const [ isOpen, setIsOpen ] = useState(true);

  const dateUpdatedAt = new Date(props.products[0].updated_at);
  console.log('newdate' + dateUpdatedAt);

  const onSelect = () => {
    setIsOpen(isOpen);
  };

  const onToggle = () => {
    setIsOpen(isOpen);
  };

  const APIDataListItem = (
      <DataListItem aria-labelledby="single-action-item1">
      <DataListItemRow>
        <DataListItemCells
          dataListCells={[
            <DataListCell key="primary content">
              <a href={props.productsPath + '/' + props.products[0].id} id="single-action-item1">
                {props.products[0].name}
              </a>
            </DataListCell>,
            <DataListCell key="secondary content" className="dashboard-list-secondary">
              {dateUpdatedAt.toUTCString()}
            </DataListCell>
          ]}
        />
        <DataListAction
          aria-labelledby="multi-actions-item1 multi-actions-action1"
          id="actions-menu"
          aria-label="Actions"
          isPlainButtonAction
        >
          <Dropdown
            isPlain
            id="actions-menu"
            position={DropdownPosition.right}
            isOpen={isOpen}
            onSelect={onSelect}
            className="dashboard-list-item-action"
            toggle={<KebabToggle onToggle={onToggle} />}
            dropdownItems={[
              <DropdownItem key="link" href={props.productsPath + '/' + props.products[0].id}>
                Overview
              </DropdownItem>,
              <DropdownItem key="link" href={props.productsPath + '/' + props.products[0].id}>
                Analytics
              </DropdownItem>,
              <DropdownItem key="link" href={props.productsPath + '/' + props.products[0].id + '/applications'}>
                Applications
              </DropdownItem>,
              <DropdownItem key="link" href={props.productsPath + '/' + props.products[0].id + "/api_docs"}>
                ActiveDocs
              </DropdownItem>,
              <DropdownItem key="link" href={props.productsPath + '/' + props.products[0].id + "/integration"}>
                Integration
              </DropdownItem>
            ]}
          />
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  );

  return (
    <Card className="pf-c-card">
      <CardHeader>
          <div className="dashboard-list-icon-title-layout">
            <CubesIcon/>
            <Title headingLevel="h1" size="xl">
              Backends
            </Title>
            <CardActions>
            <Button component="a" variant="primary" href={props.newProductPath}>
              New Product
            </Button>
          </CardActions>
          </div>
          <div className="dashboard-list-subtitle">
            Most recently created
          </div>
      </CardHeader>
      <CardBody>
        <DataList>
          {APIDataListItem}
        </DataList>
      </CardBody>
      <CardFooter>
        <Button variant="link" component="a" isInline href="">
          Go to Products
        </Button>
      </CardFooter>
    </Card>
  )
}

const ProductsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsWidget {...props} />, containerId)

export { ProductsWidgetWrapper }
