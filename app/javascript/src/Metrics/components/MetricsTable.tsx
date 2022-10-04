import {
  Button,
  Divider,
  Pagination as PFPagination,
  PaginationVariant,
  Toolbar,
  ToolbarGroup,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import { CheckIcon } from '@patternfly/react-icons'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { PaginationProps } from '@patternfly/react-core'
import type { TabKey } from 'Metrics/types'
import type { Metric } from 'Types'
import type { FunctionComponent, ReactElement } from 'react'

import './MetricsTable.scss'

type Props = {
  activeTabKey: TabKey,
  mappingRulesPath: string,
  addMappingRulePath: string,
  metrics: Metric[],
  metricsCount: number,
  createButton: React.ReactNode
}

const MetricsTable: FunctionComponent<Props> = ({
  activeTabKey,
  mappingRulesPath,
  addMappingRulePath,
  metrics,
  metricsCount,
  createButton
}) => {
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
      { title: <Button isInline component="a" href={m.path} variant="link">{m.name}</Button> },
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

  // eslint-disable-next-line react/no-multi-comp
  const Pagination = ({ variant }: Pick<PaginationProps, 'variant'>): ReactElement<PaginationProps> => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={metricsCount}
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

  // TODO: wrap toolbar items in a ToolbarContent once PF upgraded
  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarGroup> {/* TODO: add variant='filter-group' after upgrading @patternfly/react-core */}
          <ToolbarItem>
            <ToolbarSearch name="query" placeholder={`Find a ${isActiveTabMetrics ? 'metric' : 'method'}`}>
              <input name="tab" type="hidden" value={activeTabKey} />
            </ToolbarSearch>
          </ToolbarItem>
          <ToolbarItem>
            {createButton}
          </ToolbarItem>
        </ToolbarGroup>
        <ToolbarGroup>
          <ToolbarItem> {/* TODO: add alignment={{ default: 'alignRight' }} after upgrading @patternfly/react-core */}
            <Pagination />
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
      <Divider />
      <Table aria-label={`${isActiveTabMetrics ? 'Metrics' : 'Methods'} table`} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { MetricsTable, Props }
