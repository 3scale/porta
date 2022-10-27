import {
  Button,
  Divider,
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
import { Pagination } from 'Common/components/Pagination'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { ISortBy, OnSort } from '@patternfly/react-table'
import type { EmailConfiguration } from 'EmailConfigurations/types'
import type { FunctionComponent } from 'react'

import './EmailConfigurationsTable.scss'

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
            <Pagination itemCount={emailConfigurationsCount} />
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
        <Pagination itemCount={emailConfigurationsCount} variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { EmailConfigurationsTable, Props }
