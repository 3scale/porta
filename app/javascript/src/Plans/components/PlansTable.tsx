import {
  Button,
  Divider,
  PaginationVariant,
  Toolbar,
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

import type { IActionsResolver, ISortBy, OnSort } from '@patternfly/react-table'
import type { Action, Plan } from 'Types'

import './PlansTable.scss'

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
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a plan" />
        </ToolbarItem>
        <ToolbarItem> {/* TODO: add alignment={{ default: 'alignRight' }} after upgrading @patternfly/react-core */}
          <Pagination itemCount={count} />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table actionResolver={actionResolver} aria-label="Plans Table" cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination itemCount={count} variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { PlansTable, Props }
