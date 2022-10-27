import * as React from 'react'

import {
  Button,
  Card,
  CardBody,
  PageSection,
  PageSectionVariants,
  Tabs,
  Tab
} from '@patternfly/react-core'
import { MetricsTable } from 'Metrics'

import type { TabKey } from 'Metrics'
import type { Metric } from 'Types'

import './IndexPage.scss'

type Props = {
  metrics: Array<Metric>,
  metricsCount: number,
  infoCard: React.ReactNode,
  mappingRulesPath: string,
  addMappingRulePath: string,
  createMetricPath: string
};

const IndexPage = (
  {
    metrics,
    metricsCount,
    infoCard,
    mappingRulesPath,
    addMappingRulePath,
    createMetricPath
  }: Props
): React.ReactElement => {
  const url = new URL(window.location.href)
  const isActiveTabMetrics = url.searchParams.get('tab') === 'metrics'
  const activeTabKey: TabKey = isActiveTabMetrics ? 'metrics' : 'methods'

  const handleTabClick = (_event: any, tabKey: string | number) => {
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
        <Tab eventKey="methods" title="Methods"></Tab>
        <Tab eventKey="metrics" title="Metrics"></Tab>
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
            mappingRulesPath={mappingRulesPath}
            addMappingRulePath={addMappingRulePath}
            metrics={metrics}
            metricsCount={metricsCount}
            createButton={(
            <Button
              href={createMetricPath}
              component="a"
              variant="primary"
              isInline>{`Add a ${isActiveTabMetrics ? 'metric' : 'method'}`}
            </Button>
            )}
          />
        </Card>
      </PageSection>
    </div>
  )
}

export { IndexPage, Props }
