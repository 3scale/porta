// @flow

import * as React from 'react'

import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'

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
  const currentTabKey = (new URL(window.location.href)).searchParams.get('tab')
  return (
    <IndexPage
      metrics={metrics}
      metricsCount={metricsCount}
      infoCard={currentTabKey === 'metrics' ? (
        <>
          Hits is the built-in metric to which all methods report. Additional top-level metrics can be added here in order to track other usage
          that shouldn't increase the hit count. A metric needs to be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> section of the
          integration page so specific calls to your API up the count of specific metrics.
        </>
      ) : (
        <>
          Add the methods of this API to get data on their individual usage. Method calls trigger the built-in Hits-metric. Usage
          limits and pricing rules for individual methods are defined from within each <a href={applicationPlansPath}>Application plan</a>. A method
          needs to be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> section for the integration page so specific calls to
          your API up the count of specific methods.
        </>
      )}
      createMetricPath={createMetricPath}
    />
  )
}

const ProductIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductIndexPage {...props} />, containerId)

export { ProductIndexPage, ProductIndexPageWrapper }
