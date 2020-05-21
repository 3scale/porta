// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import SwaggerUI from 'swagger-ui-react'
import { WrappedComponentsPlugin } from 'ActiveDocs/customize/wrappedComponents'
import 'swagger-ui-react/swagger-ui.css'

type ActiveDocsSpecProps = {
  accountData: {
    [string]: Array<mixed>
  },
  url: string,
}

const ActiveDocsSpec = ({ url, accountData }: ActiveDocsSpecProps) => {
  const RootInjectsPlugin = (system) => {
    return {
      rootInjects: {
        accountData
      }
    }
  }

  return <SwaggerUI url={url} plugins={[RootInjectsPlugin, WrappedComponentsPlugin]} />
}

const ActiveDocsSpecWrapper = (props: ActiveDocsSpecProps, id: string) =>
  createReactWrapper(<ActiveDocsSpec {...props} />, id)

export { ActiveDocsSpec, ActiveDocsSpecWrapper }
