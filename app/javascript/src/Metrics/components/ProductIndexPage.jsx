// @flow

import * as React from 'react'

import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'
import {
  List,
  ListItem
} from '@patternfly/react-core'

import type { Metric } from 'Types'

type Props = {
  applicationPlansPath: string,
  createMetricPath: string,
  mappingRulesPath: string,
  metrics: Array<Metric>,
  metricsCount: number
}

const ProductIndexPage = ({
  applicationPlansPath,
  createMetricPath,
  mappingRulesPath,
  metrics,
  metricsCount
}: Props): React.Node => {
  const isActiveTabMetrics = new URL(window.location.href).searchParams.get('tab') === 'metrics'
  return (
    <IndexPage
      metrics={metrics}
      metricsCount={metricsCount}
      infoCard={isActiveTabMetrics ? (
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
      createMetricPath={createMetricPath}
    />
  )
}

const ProductIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductIndexPage {...props} />, containerId)

export { ProductIndexPage, ProductIndexPageWrapper }

/**
Add the methods of this API to get data on their individual usage. Method calls trigger the built-in Hits-metric. Usage
          limits and pricing rules for individual methods are defined from within each <a href={applicationPlansPath}>Application plan</a>. A method
          needs to be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> section for the integration page so specific calls to
          your API up the count of specific methods.
*/
