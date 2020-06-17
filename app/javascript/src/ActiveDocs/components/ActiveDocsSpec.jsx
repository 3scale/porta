// @flow

import React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import SwaggerUI from 'swagger-ui-react'
import 'swagger-ui-react/swagger-ui.css'
import type { SwaggerResponse } from 'Types/SwaggerTypes'

type ActiveDocsSpecProps = {
 url: string,
 responseInterceptor: (response: SwaggerResponse) => (response: SwaggerResponse, accountDataUrl: string) => SwaggerResponse
}

const ActiveDocsSpec = ({ url, responseInterceptor }: ActiveDocsSpecProps) => (
  <SwaggerUI
    url={url}
    responseInterceptor={responseInterceptor}
  />
)

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) => (
  createReactWrapper(<ActiveDocsSpec {...props} />, id)
)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
