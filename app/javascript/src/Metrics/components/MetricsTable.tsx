import {
  Button,
  Divider,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import CheckIcon from '@patternfly/react-icons/dist/js/icons/check-icon'

import { Pagination } from 'Common/components/Pagination'
import { SearchInputWithSubmitButton } from 'Common/components/SearchInputWithSubmitButton'

import type { TabKey } from 'Metrics/types'
import type { Metric } from 'Types'
import type { FunctionComponent } from 'react'

interface Props {
  activeTabKey: TabKey;
  mappingRulesPath: string;
  addMappingRulePath: string;
  metrics: Metric[];
  metricsCount: number;
  createButton: React.ReactNode;
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

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInputWithSubmitButton name="query" placeholder={`Find a ${isActiveTabMetrics ? 'metric' : 'method'}`} />
          </ToolbarItem>
          <ToolbarItem>
            {createButton}
          </ToolbarItem>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={metricsCount} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      <Divider />
      <Table aria-label={`${isActiveTabMetrics ? 'Metrics' : 'Methods'} table`} cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar id="bottom-toolbar">
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={metricsCount} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </>
  )
}

export type { Props }
export { MetricsTable }
