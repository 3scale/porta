import * as React from 'react'

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
  mappingRulesPath: string,
  addMappingRulePath: string,
  metrics: Metric[],
  metricsCount: number,
  createButton: React.ReactNode
};

const MetricsTable = (
  {
    activeTabKey,
    mappingRulesPath,
    addMappingRulePath,
    metrics,
    metricsCount,
    createButton
  }: Props
): React.ReactElement => {
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
      { title: m.mapped ? (
        <a href={mappingRulesPath}>
          <CheckIcon />
        </a>
      ) : (
        // TODO: It would be nice to have the metric preselected in the Add mapping rule form
        <a href={`${addMappingRulePath}?metric_id=${m.id}`}>Add a mapping rule</a>
      ) }
    ]
  }))

  const selectPerPage = (_event: any, selectedPerPage: any) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
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

  // TODO: wrap toolbar items in a ToolbarContent once PF upgraded
  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarGroup variant='filter-group'>
          <ToolbarItem>
            <ToolbarSearch placeholder={`Find a ${isActiveTabMetrics ? 'metric' : 'method'}`} name="query">
              <input name="tab" type="hidden" value={activeTabKey} />
            </ToolbarSearch>
          </ToolbarItem>
          <ToolbarItem>
            {createButton}
          </ToolbarItem>
        </ToolbarGroup>
        <ToolbarGroup>
          <ToolbarItem align={{ default: 'alignRight' }}>
            <Pagination />
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
      <Divider />
      <Table aria-label={`${isActiveTabMetrics ? 'Metrics' : 'Methods'} table`} cells={tableColumns} rows={tableRows}>
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
