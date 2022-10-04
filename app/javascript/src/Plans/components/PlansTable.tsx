import {
  Button,
  Divider,
  Pagination as PFPagination,
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
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type {
  IActionsResolver,
  ISortBy,
  OnSort
} from '@patternfly/react-table'
import type { OnPerPageSelect, PaginationProps } from '@patternfly/react-core'
import type { Action, Plan } from 'Types'

import './PlansTable.scss'

export type Props = {
  columns: Array<{
    attribute: string,
    title: string
  }>,
  plans: Plan[],
  count: number,
  searchHref: string,
  onAction: (action: Action) => void
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
    plans[rowIndex as number].actions.map(a => ({
      title: a.title,
      onClick: () => onAction(a)
    }))

  const url = new URL(window.location.href)

  const sortParam = url.searchParams.get('sort')
  const sortBy: ISortBy = {
    index: columns.findIndex(c => c.attribute === sortParam),
    direction: (url.searchParams.get('direction') as 'asc' | 'desc' | undefined) || 'desc'
  }

  const onSort: OnSort = (_event, index, direction) => {
    url.searchParams.set('direction', direction)
    url.searchParams.set('sort', columns[index].attribute)
    window.location.replace(url.toString())
  }

  const selectPerPage: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  // eslint-disable-next-line react/no-multi-comp
  const Pagination = ({ variant }: { variant?: PaginationProps['variant'] }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={count}
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

  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a plan" />
        </ToolbarItem>
        <ToolbarItem> {/* TODO: add alignment={{ default: 'alignRight' }} after upgrading @patternfly/react-core */}
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table actionResolver={actionResolver} aria-label="Plans Table" cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { PlansTable }
