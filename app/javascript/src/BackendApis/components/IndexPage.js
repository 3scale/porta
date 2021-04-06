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

import 'BackendApis/styles/backends.scss'

type Props = {
  backendsCount: number,
  backends: Array<{
    id: number,
    system_name: string,
    private_endpoint: string,
    link: string,
    links: Array<{
      name: string,
      path: string
    }>,
    name: string,
    products_count: number,
    type: string,
    updated_at: string,
  }>
}

const BackendsIndexPage = ({ backendsCount, backends }: Props) => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Private base URL',
    'Linked products'
  ]

  const tableRows = backends.map((tableRow) => ({
    cells: [
      { title: <Button href={tableRow.links[1].path} component="a" variant="link" isInline>{tableRow.name}</Button> },
      tableRow.system_name,
      <span className="api-table-timestamp">{tableRow.updated_at}</span>,
      tableRow.private_endpoint,
      tableRow.products_count
    ]
  }))

  const linkToPage = (rowId, actionNumber) => {
    const { path } = backends[rowId].links[actionNumber]
    window.location.href = path
  }

  const tableActions = ['Edit', 'Overview', 'Analytics', 'Methods and Metrics', 'Mapping Rules'].map((title, i) => ({
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
        itemCount={backendsCount}
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
          <Title headingLevel="h1" size="2xl">Backends</Title>
        </LevelItem>
        <LevelItem>
          <Button
            data-testid="backendsIndexCreateBackend-buttonLink"
            variant="primary"
            component="a"
            href="/p/admin/backend_apis/new"
          >
            Create Backend
          </Button>
        </LevelItem>
      </Level>
      <p className="api-table-description">
        Explore and manage all your internal APIs.
      </p>
      <Divider/>
      <Toolbar id="top-toolbar" className="pf-c-toolbar">
        <div className="pf-c-toolbar__content">
          <ToolbarItem>
            <Form id="new_search" action="/p/admin/backend_apis" acceptCharset="UTF-8" method="get">
              <InputGroup className="api-table-search">
                <input name="utf8" type="hidden" value="✓" />
                <TextInput placeholder="Find a Backend" name="search[query]" id="findBackend" type="search" aria-label="Find a backend" />
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

const BackendsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendsIndexPage {...props} />, containerId)

export { BackendsIndexPageWrapper }
