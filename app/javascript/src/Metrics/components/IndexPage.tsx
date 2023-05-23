import {
  Button,
  Card,
  CardBody,
  Flex,
  FlexItem,
  PageSection,
  PageSectionVariants,
  Tab,
  TabContent,
  TabContentBody,
  TabTitleText,
  Tabs,
  Text,
  TextContent
} from '@patternfly/react-core'

import { MetricsTable } from 'Metrics/components/MetricsTable'

import type { TabsProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'
import type { TabKey } from 'Metrics/types'
import type { Metric } from 'Types'

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

  const handleTabClick: TabsProps['onSelect'] = (_event, tabKey) => {
    url.searchParams.set('tab', String(tabKey))
    url.searchParams.delete('query')
    url.searchParams.delete('page')
    url.searchParams.delete('utf8')
    window.location.replace(url.toString())
  }

  return (
    <div id="metrics-index-page">
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">Methods and Metrics</Text>
        </TextContent>
      </PageSection>

      <PageSection type="tabs">
        <Tabs
          usePageInsets
          activeKey={activeTabKey}
          onSelect={handleTabClick}
        >
          <Tab eventKey="methods" title={<TabTitleText>Methods</TabTitleText>} />
          <Tab eventKey="metrics" title={<TabTitleText>Metrics</TabTitleText>} />
        </Tabs>
      </PageSection>

      <PageSection>
        <TabContent id="method-metrics-info-card">
          <TabContentBody>
            <Flex className="pf-u-h-100" direction={{ default: 'column' }}>
              <FlexItem flex={{ default: 'flex_1' }}>
                <Card>
                  <CardBody>
                    {infoCard}
                  </CardBody>
                </Card>
              </FlexItem>

              <FlexItem flex={{ default: 'flex_1' }}>
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
              </FlexItem>
            </Flex>
          </TabContentBody>
        </TabContent>
      </PageSection>
    </div>
  )
}

export type { Props }
export { IndexPage }
