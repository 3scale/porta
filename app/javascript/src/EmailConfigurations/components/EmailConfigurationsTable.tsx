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
import { SearchInputWithSubmitButton } from 'Common/components/SearchInputWithSubmitButton'

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
    direction: (url.searchParams.get('direction') as ISortBy['direction']) ?? 'desc'
  }

  const onSort: OnSort = (_event, _index, direction) => {
    url.searchParams.set('direction', direction)
    window.location.replace(url.toString())
  }

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInputWithSubmitButton name="query" placeholder="Find an email" />
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
