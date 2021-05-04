// @flow

import * as React from 'react'

import { IndexPage } from 'Metrics'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  applicationPlansPath: string,
  mappingRulesPath: string
}

const ProductIndexPage = ({
  applicationPlansPath,
  mappingRulesPath
}: Props): React.Node => (
  <IndexPage infoCard={(
    <>
      Add the methods of this API to get data on their individual usage. Method calls trigger the built-in Hits-metric. Usage
      limits and pricing rules for individual methods are defined from within each <a href={applicationPlansPath}>Application plan</a>. A method
      needs to be mapped to one or more URL patterns in the <a href={mappingRulesPath}>Mapping rules</a> section for the integration page so specific calls to
      your API up the count of specific methods.
    </>
  )} />
)

const ProductIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductIndexPage {...props} />, containerId)

export { ProductIndexPage, ProductIndexPageWrapper }
