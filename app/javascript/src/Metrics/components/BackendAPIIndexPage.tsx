import { IndexPage } from 'Metrics/components/IndexPage'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { List, ListItem } from '@patternfly/react-core'
import { isActiveTab } from 'utilities/isActiveTab'

import type { FunctionComponent } from 'react'
import type { Metric } from 'Types'

interface Props {
  addMappingRulePath: string;
  createMetricPath: string;
  mappingRulesPath: string;
  metrics: Metric[];
  metricsCount: number;
}

const BackendAPIIndexPage: FunctionComponent<Props> = ({
  addMappingRulePath,
  createMetricPath,
  mappingRulesPath,
  metrics,
  metricsCount
}) => (
  <IndexPage
    addMappingRulePath={addMappingRulePath}
    createMetricPath={createMetricPath}
    infoCard={isActiveTab('metrics') ? (
      <>
      Metrics track backend usage. Metrics have these features:
        <List>
          <ListItem><i>Hits</i> is the 3scale native metric to which all methods report. This metric tracks the number of calls made to your backend.</ListItem>
          <ListItem>To track usage that does not increase the hit count, add top-level metrics.</ListItem>
          <ListItem>To have specific calls to your backend tracked by specific metrics, you must map a metric to one or more URL patterns listed in <a href={mappingRulesPath}>Mapping rules</a>.</ListItem>
        </List>
      </>
    ) : (
      <>
        Methods track backend usage. Methods have these features:
        <List>
          <ListItem>Method calls trigger the <i>Hits</i> metric.</ListItem>
          <ListItem>To have specific calls to your backend tracked by specific methods, you must map a method to one or more URL patterns listed in <a href={mappingRulesPath}>Mapping rules</a>.</ListItem>
          <ListItem>Define usage limits and pricing rules for individual methods from within a product's Application plan.</ListItem>
        </List>
      </>
    )}
    mappingRulesPath={mappingRulesPath}
    metrics={metrics}
    metricsCount={metricsCount}
  />
)

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendAPIIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<BackendAPIIndexPage {...props} />, containerId) }

export { BackendAPIIndexPage, BackendAPIIndexPageWrapper, Props }
