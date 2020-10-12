// @flow

import React, {useState} from 'react'
import {
  Level,
  LevelItem,
  InputGroup,
  TextInput,
  Button,
  ButtonVariant,
  PageSection,
  Pagination,
  PaginationVariant,
  PageSectionVariants,
  Title,
  Divider,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import SearchIcon from '@patternfly/react-icons/dist/js/icons/search-icon'
import 'Products/components/styles/products.scss'
import 'patternflyStyles/dashboard'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  products: Array<{
    apps_count: number,
    backends_count: number,
    id: number,
    link: string,
    links: Array<{
      name: string,
      path: string
    }>,
    name: string,
    type: string,
    unread_alerts_count: number,
    updated_at: string
  }>
}

const ProductsIndexPage = (props: Props) => {
  console.log('THIS IS THE PROPS' + JSON.stringify(props))

  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Applications',
    'Backends contained',
    'Unread alerts'
  ]

  const [passedInProps, setPassedInProps] = useState(props)
  console.log('what is the state' + setPassedInProps)

  const tableRows = props.products.map((tableRow, index) => {
    return {
      cells: [
        { title: <Button href={tableRow.links[1].path} component="a" variant="link" isInline>{tableRow.name}</Button> },
        tableRow.system_name,
        <span className="api-table-timestamp">{tableRow.updated_at}</span>,
        tableRow.apps_count,
        tableRow.backends_count,
        tableRow.unread_alerts_count
      ]
    }
  })

  const linkToPage = (event, rowId, rowData, extra, actionNumber) => {
    const path = passedInProps && passedInProps.products[rowId].links[actionNumber].path
    window.location.href = path
  }

  const tableActions = () => [
    {
      title: 'Edit',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 0)
    },
    {
      title: 'Overview',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 1)
    },
    {
      title: 'Analytics',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 2)
    },
    {
      title: 'Applications',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 3)
    },
    {
      title: 'ActiveDocs',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 4)
    },
    {
      title: 'Integration',
      onClick: (event, rowId, rowData, extra) => linkToPage(event, rowId, rowData, extra, 5)
    }
  ]

  const url = new URL(window.location.href)
  var perPage = url.searchParams.get('per_page')
  console.log('what is perPage' + perPage)
  var page = url.searchParams.get('page')
  console.log('what is page' + page)

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToNextPage = (_event, number) => {
    console.log('what is number' + number)
    console.log('NEXT PAGEEEEE')
    url.searchParams.set('page', number)
    window.location.href = url.toString()
  }

  const goToPreviousPage = (_event, number) => {
    url.searchParams.set('page', number)
    window.location.href = url.toString()
  }

  const onFirstClick = (_event, number) => {
    url.searchParams.set('page', number)
    window.location.href = url.toString()
  }

  const onLastClick = (_event, number) => {
    url.searchParams.set('page', number)
    window.location.href = url.toString()
  }

  return (
    <>
      <PageSection className="api-table-page-section" variant={PageSectionVariants.light}>
        <Level>
          <LevelItem>
            <Title headingLevel="h1" size="2xl">Products</Title>
          </LevelItem>
          <LevelItem>
            <Button variant="primary" component="a" href="/apiconfig/services/new">
              Create Product
            </Button>
          </LevelItem>
        </Level>
        <p className="api-table-description">
          Explore and manage all customer-facing APIs that contain one or more of your Backends.
        </p>
        <Divider/>
        <Toolbar id="top-toolbar" className="pf-c-toolbar">
          <div className="pf-c-toolbar__content">
            <ToolbarItem>
              <InputGroup className="api-table-search">
                <TextInput placeholder="Find a Product" name="findProduct" id="findProduct" type="search" aria-label="Find a product" />
                <Button variant={ButtonVariant.control} aria-label="search button for search input">
                  <SearchIcon />
                </Button>
              </InputGroup>
            </ToolbarItem>
            <ToolbarItem className="api-toolbar-pagination" align={{ default: 'alignRight' }}>
              <Pagination
                widgetId="pagination-options-menu-top"
                itemCount={26}
                perPage={Number(perPage) === 0 ? 20 : perPage}
                page={Number(page)}
                onNextClick={goToNextPage}
                onPreviousClick={goToPreviousPage}
                onPerPageSelect={selectPerPage}
                onFirstClick={onFirstClick}
                onLastClick={onLastClick}
                perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
              />
            </ToolbarItem>
          </div>
        </Toolbar>
        <Table aria-label="Actions Table" actions={tableActions()} cells={tableColumns} rows={tableRows}>
          <TableHeader />
          <TableBody />
        </Table>
        <Toolbar id="bottom-toolbar" className="pf-c-toolbar">
          <div className="pf-c-toolbar__content">
            <ToolbarItem className="api-toolbar-pagination" align={{ default: 'alignRight' }}>
              <Pagination
                widgetId="pagination-options-menu-top"
                itemCount={26}
                perPage={Number(perPage) === 0 ? 20 : perPage}
                page={Number(page)}
                variant={PaginationVariant.bottom}
                onNextClick={goToNextPage}
                onPreviousClick={goToPreviousPage}
                onPerPageSelect={selectPerPage}
                onFirstClick={onFirstClick}
                onLastClick={onLastClick}
                perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
              />
            </ToolbarItem>
          </div>
        </Toolbar>
      </PageSection>
    </>
  )
}

const ProductsIndexPageWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsIndexPage {...props} />, containerId)

export { ProductsIndexPageWrapper }
