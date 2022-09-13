import * as React from 'react'
import {
  Button,
  Divider,
  Pagination as PFPagination,
  PaginationVariant,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  sortable,
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import type { Plan, Action } from 'Types'

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
};

const PlansTable = (
  {
    columns,
    plans,
    count,
    searchHref,
    onAction
  }: Props
): React.ReactElement => {
  const tableColumns = columns.map(c => ({ title: c.title, transforms: [sortable] }))

  const tableRows = plans.map(p => ({
    disableActions: false,
    cells: [
      { title: <Button href={p.editPath} component="a" variant="link" isInline>{p.name}</Button> },
      { title: <Button href={p.contractsPath} component="a" variant="link" isInline>{p.contracts}</Button> },
      p.state
    ]
  }))

  const actionResolver = (_rowData: any, {
    rowIndex
  }: {
    rowIndex: number
  }) =>
    plans[rowIndex].actions.map(a => ({
      title: a.title,
      onClick: () => onAction(a)
    }))

  const url = new URL(window.location.href)

  const sortParam = url.searchParams.get('sort')
  const sortBy = {
    index: columns.findIndex(c => c.attribute === sortParam),
    direction: url.searchParams.get('direction')
  } as const

  const onSort = (_event: any, index: any, direction: any) => {
    url.searchParams.set('direction', direction)
    url.searchParams.set('sort', columns[index].attribute)
    window.location.replace(url.toString())
  }

  const selectPerPage = (_event: any, selectedPerPage: any) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  const Pagination = ({
    variant
  }: {
    variant?: string
  }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={count}
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

  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <ToolbarSearch
            placeholder="Find a plan"
            inputAriaLabel="Find a plan"
          />
        </ToolbarItem>
        <ToolbarItem align={{ default: 'alignRight' }}>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table aria-label="Plans Table" actionResolver={actionResolver} cells={tableColumns} rows={tableRows} sortBy={sortBy} onSort={onSort}>
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
