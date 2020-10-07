// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  backends: Array<{
    id: number,
    link: string,
    links: Array<{
      name: string,
      path: string
    }>,
    name: string,
    products_count: number,
    type: string,
    updated_at: string,
  }>
}

const BackendsIndexPage = (props: Props) => {
  console.log(props)

  return (
    <div>Backends Index</div>
  )
}

const BackendsIndexPageWrapper = (props: Props, containerId: string) => createReactWrapper(<BackendsIndexPage {...props} />, containerId)

export { BackendsIndexPageWrapper }
