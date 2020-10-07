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
  // PaginationVariant,
  PageSectionVariants,
  Title,
  Divider,
  Toolbar,
  ToolbarItem,
  ToolbarContent
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

  const [perPage, setPerPage] = useState(20)
  const [page, setPage] = useState(1)
  const tableColumns = [
    'Name',
    'System name',
    'Recently updated',
    'Hits (last 30 days)',
    'Applications',
    'Backends used',
    'Unread alerts'
  ]

  const tableRows = props.products.map((tableRow) => {
    return {
      cells: [
        { title: <a href="/">{tableRow.name}</a> },
        '',
        <span className="api-table-timestamp">{tableRow.updated_at}</span>,
        '',
        tableRow.apps_count,
        tableRow.backends_count,
        tableRow.unread_alerts_count
      ]
    }
  })

  const tableActions = [
    {
      title: <a href="/">Overview</a>
    },
    {
      title: <a href="/">Analytics</a>
    },
    {
      title: <a href="/">Applications</a>
    },
    {
      title: <a href="/">ActiveDocs</a>
    },
    {
      title: <a href="/">Integration</a>
    }
  ]

  const onSetPage = (_event, pageNumber) => {
    setPage(pageNumber)
  }

  const onPerPageSelect = (_event, perPage) => {
    setPerPage(perPage)
  }

  return (
    <React.Fragment>
      <PageSection variant={PageSectionVariants.light}>
        <Level>
          <LevelItem>
            <Title headingLevel="h1" size="2xl">API Products</Title>
          </LevelItem>
          <LevelItem>
            <Button variant="primary">
              New Product
            </Button>
          </LevelItem>
        </Level>
        <p className="api-table-description">Here is some content about Products. We could also include a link to documentation.</p>
      </PageSection>
      <Divider/>
      <PageSection variant={PageSectionVariants.light}>
        <Toolbar id="top-toolbar">
          <ToolbarContent>
            <ToolbarItem>
              <InputGroup className="api-table-search">
                <TextInput placeholder="Find a product" name="findProduct" id="findProduct" type="search" aria-label="Find a product" />
                <Button variant={ButtonVariant.control} aria-label="search button for search input">
                  <SearchIcon />
                </Button>
              </InputGroup>
            </ToolbarItem>
            <ToolbarItem variant="pagination" align={{ default: 'alignRight' }}>
              <Pagination
                itemCount={37}
                perPage={perPage}
                page={page}
                onSetPage={onSetPage}
                widgetId="pagination-options-menu-top"
                onPerPageSelect={onPerPageSelect}
              />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
        <Table aria-label="Actions Table" actions={tableActions} cells={tableColumns} rows={tableRows}>
          <TableHeader />
          <TableBody />
        </Table>
        {/* <Toolbar id="bottom-toolbar">
          <ToolbarContent>
            <ToolbarItem variant="pagination" align={{ default: 'alignRight' }}>
              <Pagination
                itemCount={37}
                perPage={perPage}
                page={page}
                variant={PaginationVariant.bottom}
                onSetPage={onSetPage}
                widgetId="pagination-options-menu-top"
                onPerPageSelect={onPerPageSelect}
              />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar> */}
      </PageSection>
    </React.Fragment>
  )
}

const ProductsIndexPageWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsIndexPage {...props} />, containerId)

export { ProductsIndexPageWrapper }
