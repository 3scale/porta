// @flow

import * as React from 'react'
import {
  Button,
  ButtonVariant,
  Divider,
  Form,
  InputGroup,
  Pagination as PFPagination,
  PaginationVariant,
  TextInput,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import type { ApplicationPlan, Action } from 'Types'

import './ApplicationPlansTable.scss'

export type Props = {
  plans: ApplicationPlan[],
  count: number,
  searchHref: string,
  onAction: (action: Action) => void
}

const ApplicationPlansTable = ({ plans, count, searchHref, onAction }: Props): React.Node => {
  const tableColumns = [
    { title: 'Name' },
    { title: 'Applications' },
    { title: 'State' }
  ]

  const tableRows = plans.map(p => ({
    disableActions: false,
    cells: [
      { title: <Button href={p.editPath} component="a" variant="link" isInline>{p.name}</Button> },
      { title: <Button href={p.applicationsPath} component="a" variant="link" isInline>{p.applications}</Button> },
      p.state
    ]
  }))

  const actionResolver = (_rowData, { rowIndex }: { rowIndex: number }) =>
    plans[rowIndex].actions.map(a => ({
      title: a.title,
      onClick: () => onAction(a)
    }))

  const url = new URL(window.location.href)

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.href = url.toString()
  }

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.href = url.toString()
  }

  const Pagination = ({ variant }: { variant?: string }) => {
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
        perPageOptions={[10, 20].map(n => ({ title: n, value: n }))}
        variant={variant}
      />
    )
  }

  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <Form action={searchHref} acceptCharset="UTF-8" method="get">
            <InputGroup>
              <input name="utf8" type="hidden" value="✓" />
              <TextInput placeholder="Find an Application plan" name="search[query]" type="search" aria-label="Find an Application plan" />
              <Button variant={ButtonVariant.control} aria-label="search button for search input" type="submit">
                <SearchIcon />
              </Button>
            </InputGroup>
          </Form>
        </ToolbarItem>
        <ToolbarItem align={{ default: 'alignRight' }}>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table aria-label="Plans Table" actionResolver={actionResolver} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { ApplicationPlansTable }
