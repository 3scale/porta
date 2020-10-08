// @flow

import React, {useState} from 'react'
import {
  Button,
  Card,
  CardActions,
  CardBody,
  CardHeader,
  CardFooter,
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
} from '@patternfly/react-core'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import 'Dashboard/styles/dashboard.scss'
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

  const [ isOpenArray, setIsOpenArray ] = useState([])

  function handleChange (e) {
    const item = e.target.id
    var indexOfItem = isOpenArray.indexOf(item)

    if (indexOfItem !== -1) {
      var array = [...isOpenArray]
      if (indexOfItem === 0) {
        array.shift()
        setIsOpenArray(array)
      } else {
        var newArray = array.splice(indexOfItem, 1)
        setIsOpenArray(newArray)
      }
    } else {
      setIsOpenArray([item, ...isOpenArray])
    }
  }

  const APIDataListItem = props.products.map((api, index) => {
    let dateUpdatedAt = new Date(api.updated_at)

    return (
      <DataListItem aria-labelledby="single-action-item1">
        <DataListItemRow>
          <DataListItemCells
            dataListCells={[
              <DataListCell key="primary content">
                <a href={api.link} id="single-action-item1">
                  {api.name}
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
              isOpen={isOpenArray.indexOf(`toggle-${index}`) !== -1}
              className="dashboard-list-item-action"
              onClick={handleChange}
              toggle={<KebabToggle id={`toggle-${index}`} />}
              dropdownItems={[
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[0].path}>
                  Edit
                </DropdownItem>,
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[1].path}>
                  Overview
                </DropdownItem>,
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[2].path}>
                  Analytics
                </DropdownItem>,
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[3].path}>
                  Applications
                </DropdownItem>,
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[4].path}>
                  ActiveDocs
                </DropdownItem>,
                <DropdownItem key={`link-${index}`} href={api.link + '/' + api.links[5].path}>
                  Integration
                </DropdownItem>
              ]}
            />
          </DataListAction>
        </DataListItemRow>
      </DataListItem>
    )
  })

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
              New Product
            </Button>
          </CardActions>
        </div>
        <div className="dashboard-list-subtitle">
          Most recently updated
        </div>
      </CardHeader>
      <CardBody>
        <DataList>
          {APIDataListItem}
        </DataList>
      </CardBody>
      <CardFooter>
        <Button variant="link" component="a" isInline href={props.productsPath}>
          Go to Products
        </Button>
      </CardFooter>
    </Card>
  )
}

const ProductsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsWidget {...props} />, containerId)

export { ProductsWidgetWrapper }
