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

import type { IActionsResolver, ISortBy, OnSort } from '@patternfly/react-table'
import type { Action, Plan } from 'Types'

interface Props {
  columns: {
    attribute: string;
    title: string;
  }[];
  plans: Plan[];
  count: number;
  searchHref: string;
  onAction: (action: Action) => void;
}

const PlansTable: React.FunctionComponent<Props> = ({
  columns,
  plans,
  count,
  onAction
}) => {
  const tableColumns = columns.map(c => ({ title: c.title, transforms: [sortable] }))

  const tableRows = plans.map(p => ({
    disableActions: false,
    cells: [
      { title: <Button isInline component="a" href={p.editPath} variant="link">{p.name}</Button> },
      { title: <Button isInline component="a" href={p.contractsPath} variant="link">{p.contracts}</Button> },
      p.state
    ]
  }))

  const actionResolver: IActionsResolver = (_rowData, { rowIndex }) =>
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- safe to assume rowIndex is not undefined
    plans[rowIndex!].actions.map(a => ({
      title: a.title,
      onClick: () => { onAction(a) }
    }))

  const url = new URL(window.location.href)

  const sortParam = url.searchParams.get('sort')
  const sortBy: ISortBy = {
    index: columns.findIndex(c => c.attribute === sortParam),
    direction: (url.searchParams.get('direction') ?? 'desc') as ISortBy['direction']
  }

  const onSort: OnSort = (_event, index, direction) => {
    url.searchParams.set('direction', direction)
    url.searchParams.set('sort', columns[index].attribute)
    window.location.replace(url.toString())
  }

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInputWithSubmitButton placeholder="Find a plan" />
          </ToolbarItem>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      <Divider />
      <Table actionResolver={actionResolver} aria-label="Plans Table" cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </>
  )
}

export type { Props }
export { PlansTable }
