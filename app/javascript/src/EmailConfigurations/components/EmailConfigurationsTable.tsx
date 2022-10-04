import {
  Button,
  Divider,
  Pagination as PFPagination,
  PaginationVariant,
  Toolbar,
  ToolbarGroup,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableBody,
  TableHeader,
  sortable
} from '@patternfly/react-table'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { ISortBy, OnSort } from '@patternfly/react-table'
import type { OnPerPageSelect, PaginationProps } from '@patternfly/react-core'
import type { EmailConfiguration } from 'EmailConfigurations/types'
import type { FunctionComponent, ReactElement } from 'react'

import './EmailConfigurationsTable.scss'

type Props = {
  emailConfigurations: EmailConfiguration[],
  emailConfigurationsCount: number,
  newEmailConfigurationPath: string
}

const EmailConfigurationsTable: FunctionComponent<Props> = ({
  emailConfigurations,
  emailConfigurationsCount,
  newEmailConfigurationPath
}) => {
  const url = new URL(window.location.href)

  const tableColumns = [
    { title: 'Email' },
    { title: 'Username' },
    { title: 'Last updated', transforms: [sortable] }
  ]

  const tableRows = emailConfigurations.map(c => ({
    disableActions: false,
    cells: [
      { title: <Button isInline component="a" href={c.links.edit} variant="link">{c.email}</Button> },
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

  // eslint-disable-next-line react/no-multi-comp
  const Pagination = ({ variant }: Pick<PaginationProps, 'variant'>): ReactElement<PaginationProps> => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={emailConfigurationsCount}
        page={Number(page)}
        perPage={Number(perPage) || 20}
        perPageOptions={[10, 20].map(n => ({ title: String(n), value: n }))}
        variant={variant}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        onNextClick={(_ev, page) => goToPage(page)}
        onPageInput={(_ev, page) => goToPage(page)}
        onPerPageSelect={selectPerPage}
        onPreviousClick={(_ev, page) => goToPage(page)}
      />
    )
  }

  // TODO: wrap toolbar items in a ToolbarContent once PF upgraded
  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarGroup> {/* TODO: add variant='filter-group' after upgrading @patternfly/react-core */}
          <ToolbarItem>
            <ToolbarSearch name="query" placeholder="Find an email" />
          </ToolbarItem>
          <ToolbarItem>
            <Button
              isInline
              component="a"
              href={newEmailConfigurationPath}
              variant="primary"
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
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { EmailConfigurationsTable, Props }
