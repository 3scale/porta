// @flow

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
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import { CheckIcon } from '@patternfly/react-icons'
import { ToolbarSearch } from 'Common'

import type { TabKey } from 'Metrics'
import type { Metric } from 'Types'

import './MetricsTable.scss'

type Props = {
  activeTabKey: TabKey,
  metrics: Metric[],
  metricsCount: number,
  createButton: React.Node
}

const MetricsTable = ({
  activeTabKey,
  metrics,
  metricsCount,
  createButton
}: Props): React.Node => {
  const url = new URL(window.location.href)

  const isActiveTabMetrics = activeTabKey === 'metrics'

  const tableColumns = [
    { title: isActiveTabMetrics ? 'Metric' : 'Method' },
    { title: 'System name' },
    { title: 'Unit' },
    { title: 'Description' },
    { title: 'Mapped' }
  ]

  const tableRows = metrics.map(m => ({
    disableActions: false,
    cells: [
      { title: <Button href={m.path} component="a" variant="link" isInline>{m.name}</Button> },
      m.systemName,
      m.unit,
      m.description,
      { title: m.mapped ? <CheckIcon color="var(--pf-global--primary-color--100)" /> : '' }
    ]
  }))

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
  }

  const Pagination = ({ variant }: { variant?: string }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={metricsCount}
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
          <ToolbarSearch placeholder={`Find a ${isActiveTabMetrics ? 'metric' : 'method'}`}>
            <input name="tab" type="hidden" value={activeTabKey} />
          </ToolbarSearch>
        </ToolbarItem>
        <ToolbarItem className="pf-l-toolbar__item-left-align">
          {createButton}
        </ToolbarItem>
        <ToolbarItem align={{ default: 'alignRight' }}>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table aria-label="Plans Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar" className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { MetricsTable }
