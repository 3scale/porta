// @flow

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
  infoCard: React.Node,
  createMetricPath: string
}

const IndexPage = ({
  metrics,
  metricsCount,
  infoCard,
  createMetricPath
}: Props): React.Node => {
  const url = new URL(window.location.href)
  const isActiveTabMetrics = url.searchParams.get('tab') === 'metrics'
  const activeTabKey: TabKey = isActiveTabMetrics ? 'metrics' : 'methods'

  const handleTabClick = (_event, tabKey: TabKey) => {
    url.searchParams.set('tab', tabKey)
    window.location.replace(url.toString())
  }

  return (
    <>
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

    </>
  )
}

export { IndexPage }
