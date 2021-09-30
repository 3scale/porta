// @flow

import * as React from 'react'
import {
  Button,
  ButtonVariant,
  Divider,
  Form,
  InputGroup,
  Level,
  LevelItem,
  PageSection,
  PageSectionVariants,
  Pagination as PFPagination,
  PaginationVariant,
  TextInput,
  Title,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { createReactWrapper } from 'utilities'

import type { Product } from 'Products/types'

import './IndexPage.scss'

type Props = {
  products: Array<Product>,
  productsCount: number
}

const IndexPage = ({ productsCount, products }: Props): React.Node => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Applications',
    'Backends contained',
    'Unread alerts'
  ]

  const tableRows = products.map(tableRow => ({
    cells: [
      { title: <Button href={tableRow.links[1].path} component="a" variant="link" isInline>{tableRow.name}</Button> },
      tableRow.systemName,
      <span className="api-table-timestamp">{tableRow.updatedAt}</span>,
      tableRow.appsCount,
      tableRow.backendsCount,
      tableRow.unreadAlertsCount
    ]
  }))

  const linkToPage = (rowId, actionNumber) => {
    const { path } = products[rowId].links[actionNumber]
    window.location.href = path
  }

  const tableActions = ['Edit', 'Overview', 'Analytics', 'Applications', 'ActiveDocs', 'Integration'].map((title, i) => ({
    title,
    onClick: (_event, rowId) => linkToPage(rowId, i)
  }))

  const url = new URL(window.location.href)

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  const Pagination = ({ variant }: { variant?: string }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        widgetId="pagination-options-menu-top"
        itemCount={productsCount}
        perPage={Number(perPage) || 20}
        page={Number(page)}
        onPerPageSelect={selectPerPage}
        onNextClick={(_ev, page) => goToPage(page)}
        onPreviousClick={(_ev, page) => goToPage(page)}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
        variant={variant}
      />
    )
  }

  return (
    <PageSection className="api-table-page-section" variant={PageSectionVariants.light}>
      <Level>
        <LevelItem>
          <Title headingLevel="h1" size="2xl">Products</Title>
        </LevelItem>
        <LevelItem>
          <Button
            data-testid="productsIndexCreateProduct-buttonLink"
            variant="primary"
            component="a"
            href="/apiconfig/services/new"
          >
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
            <Form id="new_search" action="/apiconfig/services" acceptCharset="UTF-8" method="get">
              <InputGroup className="api-table-search">
                <input name="utf8" type="hidden" value="✓" />
                <TextInput placeholder="Find a Product" name="search[query]" id="findProduct" type="search" aria-label="Find a product" />
                <Button variant={ButtonVariant.control} aria-label="search button for search input" type="submit">
                  <SearchIcon />
                </Button>
              </InputGroup>
            </Form>
          </ToolbarItem>
          <ToolbarItem className="api-toolbar-pagination" align={{ default: 'alignRight' }}>
            <Pagination />
          </ToolbarItem>
        </div>
      </Toolbar>
      <Table aria-label="Actions Table" actions={tableActions} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar" className="pf-c-toolbar">
        <div className="pf-c-toolbar__content">
          <ToolbarItem className="api-toolbar-pagination" align={{ default: 'alignRight' }}>
            <Pagination variant={PaginationVariant.bottom} />
          </ToolbarItem>
        </div>
      </Toolbar>
    </PageSection>
  )
}

const ProductsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, ProductsIndexPageWrapper }
