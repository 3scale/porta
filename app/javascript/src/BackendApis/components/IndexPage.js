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
import 'BackendApis/styles/backends.scss'
import 'patternflyStyles/dashboard'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  backendsCount: number,
  backends: Array<{
    id: number,
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

const BackendsIndexPage = (props: Props) => {
  console.log('THIS IS THE PROPS' + JSON.stringify(props))

  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Private base URL',
    'Linked products'
  ]

  const tableRows = props.backends.map((tableRow) => {
    return {
      cells: [
        { title: <Button href={tableRow.links[1].path} component="a" variant="link" isInline>{tableRow.name}</Button> },
        tableRow.system_name,
        <span className="api-table-timestamp">{tableRow.updated_at}</span>,
        tableRow.private_endpoint,
        tableRow.products_count
      ]
    }
  })

  const linkToPage = (rowId, actionNumber) => {
    const path = props && props.backends[rowId].links[actionNumber].path
    window.location.href = path
  }

  const tableActions = () => ['Edit', 'Overview', 'Analytics', 'Methods and Metrics', 'Mapping Rules'].map((title, i) => ({
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
            <Title headingLevel="h1" size="2xl">Backends</Title>
          </LevelItem>
          <LevelItem>
            <Button variant="primary" component="a" href="/p/admin/backend_apis/new">
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
              <InputGroup className="api-table-search">
                <TextInput placeholder="Find a Backend" name="findBackend" id="findProduct" type="search" aria-label="Find a product" />
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
        <Table aria-label="Actions Table" actions={tableActions} cells={tableColumns} rows={tableRows}>
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

const BackendsIndexPageWrapper = (props: Props, containerId: string) => createReactWrapper(<BackendsIndexPage {...props} />, containerId)

export { BackendsIndexPageWrapper }
