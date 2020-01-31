// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import SwaggerUI from 'swagger-ui-react'

import 'swagger-ui-react/swagger-ui.css'

type ActiveDocsSpecProps = {
  url: string
}

const ActiveDocsSpec = ({ url }: ActiveDocsSpecProps) => <SwaggerUI url={url} />

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) => createReactWrapper(<ActiveDocsSpec {...props} />, id)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
