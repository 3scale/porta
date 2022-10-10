import {
  Button,
  Divider,
  PaginationVariant,
  Toolbar,
  ToolbarGroup,
  ToolbarItem
} from '@patternfly/react-core'
import { Pagination } from 'Common/components/Pagination'
import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import { CheckIcon } from '@patternfly/react-icons'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { TabKey } from 'Metrics/types'
import type { Metric } from 'Types'
import type { FunctionComponent } from 'react'

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
            <Pagination itemCount={metricsCount} />
          </ToolbarItem>
        </ToolbarGroup>
      </Toolbar>
      <Divider />
      <Table aria-label={`${isActiveTabMetrics ? 'Metrics' : 'Methods'} table`} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <Pagination itemCount={metricsCount} variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { MetricsTable, Props }
