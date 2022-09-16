import * as React from 'react'

import {
  Button,
  Divider,
  OnPerPageSelect,
  Pagination as PFPagination,
  PaginationProps,
  PaginationVariant,
  Toolbar,
  ToolbarGroup,
  ToolbarItem
} from '@patternfly/react-core'
import {
  sortable,
  Table,
  TableHeader,
  TableBody,
  ISortBy,
  OnSort
} from '@patternfly/react-table'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { EmailConfiguration } from 'EmailConfigurations/types'

import './EmailConfigurationsTable.scss'

type Props = {
  emailConfigurations: EmailConfiguration[],
  emailConfigurationsCount: number,
  newEmailConfigurationPath: string
};

const EmailConfigurationsTable = (
  {
    emailConfigurations,
    emailConfigurationsCount,
    newEmailConfigurationPath
  }: Props
): React.ReactElement => {
  const url = new URL(window.location.href)

  const tableColumns = [
    { title: 'Email' },
    { title: 'Username' },
    { title: 'Last updated', transforms: [sortable] }
  ]

  const tableRows = emailConfigurations.map(c => ({
    disableActions: false,
    cells: [
      { title: <Button href={c.links.edit} component="a" variant="link" isInline>{c.email}</Button> },
      c.userName,
      c.updatedAt
    ]
  }))

  const sortBy: ISortBy = {
    index: 2, // updated_at by default
    direction: (url.searchParams.get('direction') as 'asc' | 'desc' | undefined) || 'desc'
  }

  const onSort: OnSort = (_event, _index, direction) => {
    url.searchParams.set('direction', direction)
    window.location.replace(url.toString())
  }

  const selectPerPage: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page: number) => {
    url.searchParams.set('page', String(page))
    window.location.replace(url.toString())
  }

  const Pagination = ({
    variant
  }: {
    variant?: PaginationProps['variant']
  }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={emailConfigurationsCount}
        perPage={Number(perPage) || 20}
        page={Number(page)}
        onPerPageSelect={selectPerPage}
        onNextClick={(_ev, page) => goToPage(page)}
        onPreviousClick={(_ev, page) => goToPage(page)}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        onPageInput={(_ev, page) => goToPage(page)}
        perPageOptions={[10, 20].map(n => ({ title: String(n), value: n }))}
        variant={variant}
      />
    )
  }

  // TODO: wrap toolbar items in a ToolbarContent once PF upgraded
  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarGroup> {/* TODO: add variant='filter-group' after upgrading @patternfly/react-core */}
          <ToolbarItem>
            <ToolbarSearch placeholder="Find an email" name="query" />
          </ToolbarItem>
          <ToolbarItem>
            <Button
              href={newEmailConfigurationPath}
              component="a"
              variant="primary"
              isInline
            >
              Add an Email configuration
            </Button>
          </ToolbarItem>
        </ToolbarGroup>
        <ToolbarGroup>
          <ToolbarItem> {/* TODO: add alignment={{ default: 'alignRight' }} after upgrading @patternfly/react-core */}
            <Pagination />
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
      <Divider />
      {/* TODO: add NoMatchFound when no search results and a NoItemsCreateFirstOne when collection empty */}
      <Table aria-label="Email configurations table" cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar" className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { EmailConfigurationsTable, Props }
