import {
  Button,
  Card,
  CardBody,
  PageSection,
  PageSectionVariants,
  Tab,
  Tabs
} from '@patternfly/react-core'
import { MetricsTable } from 'Metrics/components/MetricsTable'

import type { FunctionComponent } from 'react'
import type { TabKey } from 'Metrics/types'
import type { Metric } from 'Types'

import './IndexPage.scss'

interface Props {
  metrics: Metric[];
  metricsCount: number;
  infoCard: React.ReactNode;
  mappingRulesPath: string;
  addMappingRulePath: string;
  createMetricPath: string;
}

const IndexPage: FunctionComponent<Props> = ({
  metrics,
  metricsCount,
  infoCard,
  mappingRulesPath,
  addMappingRulePath,
  createMetricPath
}) => {
  const url = new URL(window.location.href)
  const isActiveTabMetrics = url.searchParams.get('tab') === 'metrics'
  const activeTabKey: TabKey = isActiveTabMetrics ? 'metrics' : 'methods'

  const handleTabClick = (_event: unknown, tabKey: number | string) => {
    if (tabKey !== 'metrics' && tabKey !== 'methods') {
      throw new Error('invalid tab key')
    }
    url.searchParams.set('tab', tabKey as TabKey)
    url.searchParams.delete('query')
    url.searchParams.delete('page')
    url.searchParams.delete('utf8')
    window.location.replace(url.toString())
  }

  return (
    <div id="metrics-index-page">
      <PageSection variant={PageSectionVariants.light}>
        <h1>Methods and Metrics</h1>
      </PageSection>

      <Tabs activeKey={activeTabKey} onSelect={handleTabClick}>
        <Tab eventKey="methods" title="Methods" />
        <Tab eventKey="metrics" title="Metrics" />
      </Tabs>

      <PageSection>
        <Card>
          <CardBody>
            {infoCard}
          </CardBody>
        </Card>

        <Card>
          <MetricsTable
            activeTabKey={activeTabKey}
            addMappingRulePath={addMappingRulePath}
            createButton={(
              <Button
                isInline
                component="a"
                href={createMetricPath}
                variant="primary"
              >{`Add a ${isActiveTabMetrics ? 'metric' : 'method'}`}
              </Button>
            )}
            mappingRulesPath={mappingRulesPath}
            metrics={metrics}
            metricsCount={metricsCount}
          />
        </Card>
      </PageSection>
    </div>
  )
}

export { IndexPage, Props }
