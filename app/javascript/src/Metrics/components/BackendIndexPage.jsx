// @flow

import * as React from 'react'

import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  mappingRulesPath: string
}

const BackendIndexPage = ({
  mappingRulesPath
}: Props): React.Node => (
  <IndexPage infoCard={(
    <>
      Add the methods of this Backend to get data on their individual usage once part of a Product. Method calls trigger the built-in Hits-metric.
      Usage limits and pricing rules for individual methods are defined under context of a Product Application Plan. A method can be mapped to one
      or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> of this Backend.
    </>
  )} />
)

const BackendIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendIndexPage {...props} />, containerId)

export { BackendIndexPage, BackendIndexPageWrapper }
