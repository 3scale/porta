// @flow

import React from 'react'
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
import { createReactWrapper } from 'utilities/createReactWrapper'

import 'Products/components/styles/products.scss'
import 'patternflyStyles/dashboard'

type Props = {
  productsCount: number,
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
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Applications',
    'Backends contained',
    'Unread alerts'
  ]

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

  const linkToPage = (rowId, actionNumber) => {
    const path = props && props.products[rowId].links[actionNumber].path
    window.location.href = path
  }

  const tableActions = () => ['Edit', 'Overview', 'Analytics', 'Applications', 'ActiveDocs', 'Integration'].map((title, i) => ({
    title,
    onClick: (_event, rowId) => linkToPage(rowId, i)
  }))

  const url = new URL(window.location.href)
  var perPage = url.searchParams.get('per_page')
  var page = url.searchParams.get('page')

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  const pagination = (bottomTrue) => {
    return (
      <Pagination
        widgetId="pagination-options-menu-top"
        itemCount={props.productsCount}
        perPage={Number(perPage) === 0 ? 20 : Number(perPage)}
        page={Number(page)}
        onPerPageSelect={selectPerPage}
        onNextClick={(_ev, page) => goToPage(page)}
        onPreviousClick={(_ev, page) => goToPage(page)}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
        variant={ bottomTrue && PaginationVariant.bottom}
      />
    )
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
              {pagination()}
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
              {pagination(true)}
            </ToolbarItem>
          </div>
        </Toolbar>
      </PageSection>
    </>
  )
}

const ProductsIndexPageWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsIndexPage {...props} />, containerId)

export { ProductsIndexPageWrapper }
