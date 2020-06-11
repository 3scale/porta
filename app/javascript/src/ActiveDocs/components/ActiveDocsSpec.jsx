// @flow

import React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import SwaggerUI from 'swagger-ui-react'
import 'swagger-ui-react/swagger-ui.css'
import type { SwaggerResponse } from 'Types/SwaggerTypes'

type ActiveDocsSpecProps = {
 accountDataUrl: string,
 autocompleteOAS3: (response: SwaggerResponse, accountDataUrl: string) => Promise<SwaggerResponse>,
 url: string,
}

const ActiveDocsSpec = ({ url, accountDataUrl, autocompleteOAS3 }: ActiveDocsSpecProps) => (
  <SwaggerUI
    url={url}
    responseInterceptor={(response) => autocompleteOAS3(response, accountDataUrl)}
  />
)

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) => (
  createReactWrapper(<ActiveDocsSpec {...props} />, id)
)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
