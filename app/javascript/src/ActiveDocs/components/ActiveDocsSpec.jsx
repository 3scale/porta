// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import SwaggerUI from 'swagger-ui-react'
import { OAS3Plugins } from 'ActiveDocs/customize/plugins'

import 'swagger-ui-react/swagger-ui.css'

type ActiveDocsSpecProps = {
  url: string,
  service: {
    service: {}
  },
  plugins?: [()=>{}]
}

const ActiveDocsSpec = ({ url, service, plugins }: ActiveDocsSpecProps) => (
  <SwaggerUI url={url} plugins={OAS3Plugins} />
)

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) =>
  createReactWrapper(<ActiveDocsSpec {...props} />, id)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
