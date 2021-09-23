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

const BackendIndexPage = ({
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
          <i>Hits</i> is the built-in metric to which all methods report. Additional top-level metrics can be added here in order to track other usage that
          shouldn't increase the hit count. A metric can be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> of
          this Backend
        </>
      ) : (
        <>
          Add the methods of this Backend to get data on their individual usage once part of a Product. Method calls trigger the built-in Hits-metric.
          Usage limits and pricing rules for individual methods are defined under context of a Product <a href={applicationPlansPath}>Application plan</a>.
          A method can be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> of this Backend.
        </>
      )}
      createMetricPath={createMetricPath}
    />
  )
}

const BackendIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendIndexPage {...props} />, containerId)

export { BackendIndexPage, BackendIndexPageWrapper }
