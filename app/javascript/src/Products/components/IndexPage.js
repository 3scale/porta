// @flow

import React from 'react'
import {
  Form,
  Level,
  LevelItem,
  InputGroup,
  TextInput,
  Button,
  ButtonVariant,
  PageSection,
  Pagination as PFPagination,
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

type Props = {
  productsCount: number,
  products: Array<{
    apps_count: number,
    backends_count: number,
    id: number,
    system_name: string,
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

const ProductsIndexPage = ({ productsCount, products }: Props) => {
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
      tableRow.system_name,
      <span className="api-table-timestamp">{tableRow.updated_at}</span>,
      tableRow.apps_count,
      tableRow.backends_count,
      tableRow.unread_alerts_count
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

const ProductsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductsIndexPage {...props} />, containerId)

export { ProductsIndexPageWrapper }
