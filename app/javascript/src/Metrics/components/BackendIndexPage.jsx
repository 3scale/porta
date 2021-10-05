// @flow

import * as React from 'react'

import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Metric } from 'Types'

type Props = {
  createMetricPath: string,
  metrics: Array<Metric>,
  metricsCount: number
}

const BackendIndexPage = ({
  createMetricPath,
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
          TODO
        </>
      ) : (
        <>
          TODO
        </>
      )}
      createMetricPath={createMetricPath}
    />
  )
}

const BackendIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendIndexPage {...props} />, containerId)

export { BackendIndexPage, BackendIndexPageWrapper }
