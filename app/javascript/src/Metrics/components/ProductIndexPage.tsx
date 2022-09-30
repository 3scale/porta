
import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'
import {
  List,
  ListItem
} from '@patternfly/react-core'
import { isActiveTab } from 'utilities'

import type { Metric } from 'Types'

type Props = {
  applicationPlansPath: string,
  addMappingRulePath: string,
  createMetricPath: string,
  mappingRulesPath: string,
  metrics: Array<Metric>,
  metricsCount: number
};

const ProductIndexPage = (
  {
    applicationPlansPath,
    addMappingRulePath,
    createMetricPath,
    mappingRulesPath,
    metrics,
    metricsCount
  }: Props
): React.ReactElement => <IndexPage
  metrics={metrics}
  metricsCount={metricsCount}
  infoCard={isActiveTab('metrics') ? (
    <>
    Metrics track API usage. Metrics have these features:
    <List>
      <ListItem><i>Hits</i> is the 3scale native metric to which all methods report. This metric tracks the number of calls made to your API.</ListItem>
      <ListItem>To track usage that does not increase the hit count, add top-level metrics.</ListItem>
      <ListItem>To have specific calls to your API tracked by specific metrics, you must map a metric to one or more URL patterns listed in <a href={mappingRulesPath}>Mapping rules</a>.</ListItem>
    </List>
    </>
  ) : (
    <>
      Methods track API usage.  Methods have these features:
      <List>
        <ListItem>Method calls trigger the <i>Hits</i> metric.</ListItem>
        <ListItem>To have specific calls to your API tracked by specific methods, you must map a method to one or more URL patterns listed in <a href={mappingRulesPath}>Mapping rules</a>.</ListItem>
        <ListItem>Define usage limits and pricing rules for individual methods from within each <a href={applicationPlansPath}>Application plan</a>.</ListItem>
      </List>
    </>
  )}
  mappingRulesPath={mappingRulesPath}
  addMappingRulePath={addMappingRulePath}
  createMetricPath={createMetricPath}
/>

const ProductIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductIndexPage {...props} />, containerId)

export { ProductIndexPage, ProductIndexPageWrapper, Props }
