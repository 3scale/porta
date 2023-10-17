import {
  Button,
  Divider,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableBody,
  TableHeader,
  sortable
} from '@patternfly/react-table'

import { Pagination } from 'Common/components/Pagination'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { ISortBy, OnSort } from '@patternfly/react-table'
import type { EmailConfiguration } from 'EmailConfigurations/types'
import type { FunctionComponent } from 'react'

interface Props {
  emailConfigurations: EmailConfiguration[];
  emailConfigurationsCount: number;
  newEmailConfigurationPath: string;
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

  const sortColumn = {
    attribute: 'updated_at',
    index: 2
  }

  const tableRows = emailConfigurations.map(c => ({
    disableActions: false,
    cells: [
      { title: <Button isInline component="a" href={c.links.edit} variant="link">{c.email}</Button> },
      c.userName,
      c.updatedAt
    ]
  }))

  const sortParam = url.searchParams.get('sort')
  const sortBy: ISortBy = {
    index: sortParam === sortColumn.attribute ? sortColumn.index : -1,
    direction: (url.searchParams.get('direction') as ISortBy['direction']) ?? 'desc'
  }

  const onSort: OnSort = (_event, _index, direction) => {
    url.searchParams.set('sort', sortColumn.attribute)
    url.searchParams.set('direction', direction)
    window.location.replace(url.toString())
  }

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
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
        </ToolbarContent>
        <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
          <Pagination itemCount={emailConfigurationsCount} />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      {/* TODO: add NoMatchFound when no search results and a NoItemsCreateFirstOne when collection empty */}
      <Table aria-label="Email configurations table" cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar">
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={emailConfigurationsCount} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </>
  )
}

export type { Props }
export { EmailConfigurationsTable }
